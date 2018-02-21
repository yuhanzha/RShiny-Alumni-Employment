# -*- coding: utf-8 -*-。

import sys
import os
import copy
import time
from urllib.parse import unquote
import requests
from urllib.parse import quote
import re
from lxml import etree
from imp import reload 
try:
    from credential import * 
except: raise RuntimeError('please put your linkedin account and password in credential.py')
##############################################################################
# please put your linkedin account and password in credential.py as follow:  #
# laccount='***********'                                                     #
# lpassword='***********'                                                    #
##############################################################################

reload(sys)
#sys.setdefaultencoding('utf8')

CREDIT_GRADE = {  # 芝麻信用
    'EXCELLENT': '极好',
    'VERY_GOOD': '优秀',
    'GOOD': '良好',
    'ACCEPTABLE': '中等',
    'POOR': '较差'
}

LINKS_FINISHED = []  # 已抓取的linkedin用户


def login(laccount, lpassword):
    """ 根据账号密码登录linkedin """
    s = requests.Session()
    r = s.get('https://www.linkedin.com/uas/login')
    tree = etree.HTML(r.content)
    loginCsrfParam = ''.join(tree.xpath('//input[@id="loginCsrfParam-login"]/@value'))
    csrfToken = ''.join(tree.xpath('//input[@id="csrfToken-login"]/@value'))
    sourceAlias = ''.join(tree.xpath('//input[@id="sourceAlias-login"]/@value'))
    isJsEnabled = ''.join(tree.xpath('//input[@name="isJsEnabled"]/@value'))
    source_app = ''.join(tree.xpath('//input[@name="source_app"]/@value'))
    tryCount = ''.join(tree.xpath('//input[@id="tryCount"]/@value'))
    clickedSuggestion = ''.join(tree.xpath('//input[@id="clickedSuggestion"]/@value'))
    signin = ''.join(tree.xpath('//input[@name="signin"]/@value'))
    session_redirect = ''.join(tree.xpath('//input[@name="session_redirect"]/@value'))
    trk = ''.join(tree.xpath('//input[@name="trk"]/@value'))
    fromEmail = ''.join(tree.xpath('//input[@name="fromEmail"]/@value'))

    payload = {
        'isJsEnabled': isJsEnabled,
        'source_app': source_app,
        'tryCount': tryCount,
        'clickedSuggestion': clickedSuggestion,
        'session_key': laccount,
        'session_password': lpassword,
        'signin': signin,
        'session_redirect': session_redirect,
        'trk': trk,
        'loginCsrfParam': loginCsrfParam,
        'fromEmail': fromEmail,
        'csrfToken': csrfToken,
        'sourceAlias': sourceAlias
    }
    s.post('https://www.linkedin.com/uas/login-submit', data=payload)
    return s


def get_linkedin_url(url, s):
    """ 百度搜索出来的是百度跳转链接，要从中提取出linkedin链接 """
    try:
        r = s.get(url, allow_redirects=False)
        if r.status_code == 302 and 'Location' in r.headers.keys() and 'linkedin.com/in/' in r.headers['Location']:
            return r.headers['Location']
    except:
        print ('get linkedin url failed: %s' % url)
    return ''


def parse(content, url, f):
    """ 解析一个员工的Linkedin主页 """
    #print('parse1')
    #print(content)
    content = unquote(content).replace('&quot;', '\"')
    #print('parse2')

    profile_txt = ' '.join(re.findall('(\{[^\{]*?profile\.Profile"[^\}]*?\})', content))
    #print(profile_txt)
    #f = open('test.txt','wb')
    #f.write(str(profile_txt)
    #f.close()
    #print('saved')
    firstname = re.findall('"firstName":"(.*?)"', profile_txt)
    lastname = re.findall('"lastName":"(.*?)"', profile_txt)
    if firstname and lastname:
        f.write(url+'\t')
        print ('Name: %s%s    Linkedin: %s' % (lastname[0], firstname[0], url))
        f.write(lastname[0]+'\t'+firstname[0]+'\t')
        #summary = re.findall('"summary":"(.*?)"', profile_txt)
        #if summary:
            #print ('简介: %s' % summary[0])
            #f.write(summary[0]+',')
        #else:
            #f.write(',')

        occupation = re.findall('"headline":"(.*?)"', profile_txt)
        if occupation:
            print ('Title/Occupation: %s' % occupation[0])
            f.write(occupation[0]+'\t')
        else:f.write('\t')

        locationName = re.findall('"locationName":"(.*?)"', profile_txt)
        if locationName:
            print ('Location: %s' % locationName[0])
            f.write(locationName[0]+'\t')
        else:f.write('\t')

        networkInfo_txt = ' '.join(re.findall('(\{[^\{]*?profile\.ProfileNetworkInfo"[^\}]*?\})', content))
        connectionsCount = re.findall('"connectionsCount":(\d+)', networkInfo_txt)
        if connectionsCount:
            print ('Connections: %s' % connectionsCount[0])
            f.write(connectionsCount[0]+'\t')
        else:f.write('\t')

        '''
        sesameCredit_txt = ' '.join(re.findall('(\{[^\{]*?profile\.SesameCreditGradeInfo"[^\}]*?\})', content))
        credit_lastModifiedAt = re.findall('"lastModifiedAt":(\d+)', sesameCredit_txt)
        credit_grade = re.findall('"grade":"(.*?)"', sesameCredit_txt)
        if credit_grade and credit_grade[0] in CREDIT_GRADE.keys():
            credit_lastModifiedAt_date = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(int(credit_lastModifiedAt[0][:10]))) if credit_lastModifiedAt else ''
            print ('芝麻信用: %s %s' % (CREDIT_GRADE[credit_grade[0]], '   最后更新时间: %s' % credit_lastModifiedAt_date if credit_lastModifiedAt_date else ''))

        wechat_txt = ' '.join(re.findall('(\{[^\{]*?profile\.WeChatContactInfo"[^\}]*?\})', content))
        wechat_image = re.findall('"qrCodeImageUrl":"(http.*?)"', wechat_txt)
        wechat_name = re.findall('"name":"(.*?)"', wechat_txt)
        if wechat_name:
            print ('微信昵称: %s %s' % (wechat_name[0], '    二维码(链接): %s' % wechat_image[0].replace('&#61;', '=').replace('&amp;', '&') if wechat_image else ''))
        elif wechat_image:
            print ('微信二维码(链接): %s' % wechat_image[0].replace('&#61;', ''))
        
        website_txt = ' '.join(re.findall('("included":.*?profile\.StandardWebsite",.*?\})', content))
        website = re.findall('"url":"(.*?)"', website_txt)
        if website:
            print ('个人网站: %s' % website[0])
        '''

        educations = re.findall('(\{[^\{]*?profile\.Education"[^\}]*?\})', content)
        if educations:
            print ('Education:')
        start_dates = []
        for one in educations:
            timePeriod = re.findall('"timePeriod":"(.*?)"', one)
            if timePeriod:
                startdate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s,startDate"[^\}]*?\})' % timePeriod[0].replace('(', '\(').replace(')', '\)'), content))
                start_year = re.findall('"year":(\d+)', startdate_txt)
                start_month = re.findall('"month":(\d+)', startdate_txt)
                startdate = ''
                if start_year:
                    startdate += '%s' % start_year[0]
                    if start_month:
                        startdate += '.%s' % start_month[0]
                start_dates.append(startdate)
        #print(start_dates)
        #print (sorted(start_dates,reverse=True))
        #print (sorted(range(len(start_dates)), key=lambda k: start_dates[k],reverse=True))
        #raise TypeError('123')
        idx = sorted(range(len(start_dates)), key=lambda k: start_dates[k],reverse=True)
        idx = idx[:min(3,len(idx))]
        write_count = 0
        for i in idx:
            one = educations[i]
            schoolName = re.findall('"schoolName":"(.*?)"', one)
            fieldOfStudy = re.findall('"fieldOfStudy":"(.*?)"', one)
            degreeName = re.findall('"degreeName":"(.*?)"', one)
            timePeriod = re.findall('"timePeriod":"(.*?)"', one)
            schoolTime = ''
            startdate = ''
            enddate = ''
            if timePeriod:
                startdate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s,startDate"[^\}]*?\})' % timePeriod[0].replace('(', '\(').replace(')', '\)'), content))
                enddate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s,endDate"[^\}]*?\})' % timePeriod[0].replace('(', '\(').replace(')', '\)'), content))
                start_year = re.findall('"year":(\d+)', startdate_txt)
                start_month = re.findall('"month":(\d+)', startdate_txt)
                end_year = re.findall('"year":(\d+)', enddate_txt)
                end_month = re.findall('"month":(\d+)', enddate_txt)
                
                if start_year:
                    startdate += '%s' % start_year[0]
                    if start_month:
                        startdate += '.%s' % start_month[0]
                
                if end_year:
                    enddate += '%s' % end_year[0]
                    if end_month:
                        enddate += '.%s' % end_month[0]
                if len(startdate) > 0 and len(enddate) == 0:
                    enddate = 'present'
                schoolTime += '   %s ~ %s' % (startdate, enddate)
            if schoolName:
                fieldOfStudy = '   %s' % fieldOfStudy[0] if fieldOfStudy else ''
                degreeName = '   %s' % degreeName[0] if degreeName else ''
                print ('    %s %s %s %s' % (schoolName[0], schoolTime, fieldOfStudy, degreeName))
                f.write(schoolName[0]+'\t'+startdate+'\t'+enddate+'\t'+fieldOfStudy+'\t'+degreeName+'\t')
                write_count += 1
        if write_count < 3:
            f.write('\t'*5*(3-write_count))

        position = re.findall('(\{[^\{]*?profile\.Position"[^\}]*?\})', content)
        if position:
            print ('Work Experience:')
        start_dates = []
        for one in position:
            timePeriod = re.findall('"timePeriod":"(.*?)"', one)
            if timePeriod:
                startdate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s,startDate"[^\}]*?\})' % timePeriod[0].replace('(', '\(').replace(')', '\)'), content))
                start_year = re.findall('"year":(\d+)', startdate_txt)
                start_month = re.findall('"month":(\d+)', startdate_txt)
                startdate = ''
                if start_year:
                    startdate += '%s' % start_year[0]
                    if start_month:
                        startdate += '.%s' % start_month[0]
                start_dates.append(startdate)
        idx = sorted(range(len(start_dates)), key=lambda k: start_dates[k],reverse = True)
        idx = idx[:min(3,len(idx))]
        idx = idx[::-1]
        
        write_count = 0
        for i in idx:
            one = position[i]
            companyName = re.findall('"companyName":"(.*?)"', one)
            title = re.findall('"title":"(.*?)"', one)
            locationName = re.findall('"locationName":"(.*?)"', one)
            timePeriod = re.findall('"timePeriod":"(.*?)"', one)
            positionTime = ''
            startdate = ''
            enddate = ''
            if timePeriod:
                startdate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s,startDate"[^\}]*?\})' % timePeriod[0].replace('(', '\(').replace(')', '\)'), content))
                enddate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s,endDate"[^\}]*?\})' % timePeriod[0].replace('(', '\(').replace(')', '\)'), content))
                start_year = re.findall('"year":(\d+)', startdate_txt)
                start_month = re.findall('"month":(\d+)', startdate_txt)
                end_year = re.findall('"year":(\d+)', enddate_txt)
                end_month = re.findall('"month":(\d+)', enddate_txt)
                
                if start_year:
                    startdate += '%s' % start_year[0]
                    if start_month:
                        startdate += '.%s' % start_month[0]
                
                if end_year:
                    enddate += '%s' % end_year[0]
                    if end_month:
                        enddate += '.%s' % end_month[0]
                if len(startdate) > 0 and len(enddate) == 0:
                    enddate = 'present'
                positionTime += '   %s ~ %s' % (startdate, enddate)
            if companyName:
                title = '   %s' % title[0] if title else ''
                locationName = '   %s' % locationName[0] if locationName else ''
                print ('    %s %s %s %s' % (companyName[0], positionTime, title, locationName))
                f.write(companyName[0]+'\t'+startdate+'\t'+enddate+'\t'+title+'\t'+locationName+'\t')
                write_count += 1
        if write_count < 3:
            f.write('\t'*5*(3-write_count))

        '''
        publication = re.findall('(\{[^\{]*?profile\.Publication"[^\}]*?\})', content)
        if publication:
            print ('出版作品:')
        for one in publication:
            name = re.findall('"name":"(.*?)"', one)
            publisher = re.findall('"publisher":"(.*?)"', one)
            if name:
                print ('    %s %s' % (name[0], '   出版社: %s' % publisher[0] if publisher else ''))

        honor = re.findall('(\{[^\{]*?profile\.Honor"[^\}]*?\})', content)
        if honor:
            print ('荣誉奖项:')
        for one in honor:
            title = re.findall('"title":"(.*?)"', one)
            issuer = re.findall('"issuer":"(.*?)"', one)
            issueDate = re.findall('"issueDate":"(.*?)"', one)
            issueTime = ''
            if issueDate:
                issueDate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s"[^\}]*?\})' % issueDate[0].replace('(', '\(').replace(')', '\)'), content))
                year = re.findall('"year":(\d+)', issueDate_txt)
                month = re.findall('"month":(\d+)', issueDate_txt)
                if year:
                    issueTime += '   发行时间: %s' % year[0]
                    if month:
                        issueTime += '.%s' % month[0]
            if title:
                print ('    %s %s %s' % (title[0], '   发行人: %s' % issuer[0] if issuer else '', issueTime))

        organization = re.findall('(\{[^\{]*?profile\.Organization"[^\}]*?\})', content)
        if organization:
            print ('参与组织:')
        for one in organization:
            name = re.findall('"name":"(.*?)"', one)
            timePeriod = re.findall('"timePeriod":"(.*?)"', one)
            organizationTime = ''
            if timePeriod:
                startdate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s,startDate"[^\}]*?\})' % timePeriod[0].replace('(', '\(').replace(')', '\)'), content))
                enddate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s,endDate"[^\}]*?\})' % timePeriod[0].replace('(', '\(').replace(')', '\)'), content))
                start_year = re.findall('"year":(\d+)', startdate_txt)
                start_month = re.findall('"month":(\d+)', startdate_txt)
                end_year = re.findall('"year":(\d+)', enddate_txt)
                end_month = re.findall('"month":(\d+)', enddate_txt)
                startdate = ''
                if start_year:
                    startdate += '%s' % start_year[0]
                    if start_month:
                        startdate += '.%s' % start_month[0]
                enddate = ''
                if end_year:
                    enddate += '%s' % end_year[0]
                    if end_month:
                        enddate += '.%s' % end_month[0]
                if len(startdate) > 0 and len(enddate) == 0:
                    enddate = '现在'
                organizationTime += '   %s ~ %s' % (startdate, enddate)
            if name:
                print ('    %s %s' % (name[0], organizationTime))

        patent = re.findall('(\{[^\{]*?profile\.Patent"[^\}]*?\})', content)
        if patent:
            print ('专利发明:')
        for one in patent:
            title = re.findall('"title":"(.*?)"', one)
            issuer = re.findall('"issuer":"(.*?)"', one)
            url = re.findall('"url":"(http.*?)"', one)
            number = re.findall('"number":"(.*?)"', one)
            localizedIssuerCountryName = re.findall('"localizedIssuerCountryName":"(.*?)"', one)
            issueDate = re.findall('"issueDate":"(.*?)"', one)
            patentTime = ''
            if issueDate:
                issueDate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s"[^\}]*?\})' % issueDate[0].replace('(', '\(').replace(')', '\)'), content))
                year = re.findall('"year":(\d+)', issueDate_txt)
                month = re.findall('"month":(\d+)', issueDate_txt)
                day = re.findall('"day":(\d+)', issueDate_txt)
                if year:
                    patentTime += '   发行时间: %s' % year[0]
                    if month:
                        patentTime += '.%s' % month[0]
                        if day:
                            patentTime += '.%s' % day[0]
            if title:
                print ('    %s %s %s %s %s %s' % (title[0], '   发行者: %s' % issuer[0] if issuer else '', '   专利号: %s' % number[0] if number else '', '   所在国家: %s' % localizedIssuerCountryName[0] if localizedIssuerCountryName else '', patentTime, '   专利详情页: %s' % url[0] if url else ''))

        project = re.findall('(\{[^\{]*?profile\.Project"[^\}]*?\})', content)
        if project:
            print ('所做项目:')
        for one in project:
            title = re.findall('"title":"(.*?)"', one)
            description = re.findall('"description":"(.*?)"', one)
            timePeriod = re.findall('"timePeriod":"(.*?)"', one)
            projectTime = ''
            if timePeriod:
                startdate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s,startDate"[^\}]*?\})' % timePeriod[0].replace('(', '\(').replace(')', '\)'), content))
                enddate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s,endDate"[^\}]*?\})' % timePeriod[0].replace('(', '\(').replace(')', '\)'), content))
                start_year = re.findall('"year":(\d+)', startdate_txt)
                start_month = re.findall('"month":(\d+)', startdate_txt)
                end_year = re.findall('"year":(\d+)', enddate_txt)
                end_month = re.findall('"month":(\d+)', enddate_txt)
                startdate = ''
                if start_year:
                    startdate += '%s' % start_year[0]
                    if start_month:
                        startdate += '.%s' % start_month[0]
                enddate = ''
                if end_year:
                    enddate += '%s' % end_year[0]
                    if end_month:
                        enddate += '.%s' % end_month[0]
                if len(startdate) > 0 and len(enddate) == 0:
                    enddate = '现在'
                projectTime += '   时间: %s ~ %s' % (startdate, enddate)
            if title:
                print ('    %s %s %s' % (title[0], projectTime, '   项目描述: %s' % description[0] if description else ''))

        volunteer = re.findall('(\{[^\{]*?profile\.VolunteerExperience"[^\}]*?\})', content)
        if volunteer:
            print ('志愿者经历:')
        for one in volunteer:
            companyName = re.findall('"companyName":"(.*?)"', one)
            role = re.findall('"role":"(.*?)"', one)
            timePeriod = re.findall('"timePeriod":"(.*?)"', one)
            volunteerTime = ''
            if timePeriod:
                startdate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s,startDate"[^\}]*?\})' % timePeriod[0].replace('(', '\(').replace(')', '\)'), content))
                enddate_txt = ' '.join(re.findall('(\{[^\{]*?"\$id":"%s,endDate"[^\}]*?\})' % timePeriod[0].replace('(', '\(').replace(')', '\)'), content))
                start_year = re.findall('"year":(\d+)', startdate_txt)
                start_month = re.findall('"month":(\d+)', startdate_txt)
                end_year = re.findall('"year":(\d+)', enddate_txt)
                end_month = re.findall('"month":(\d+)', enddate_txt)
                startdate = ''
                if start_year:
                    startdate += '%s' % start_year[0]
                    if start_month:
                        startdate += '.%s' % start_month[0]
                enddate = ''
                if end_year:
                    enddate += '%s' % end_year[0]
                    if end_month:
                        enddate += '.%s' % end_month[0]
                if len(startdate) > 0 and len(enddate) == 0:
                    enddate = '现在'
                volunteerTime += '   时间: %s ~ %s' % (startdate, enddate)
            if companyName:
                print ('    %s %s %s' % (companyName[0], volunteerTime, '   角色: %s' % role[0] if role else ''))
        '''
        f.write('\n')
        f.close()
    print ('\n\n')
    


def crawl(url, s, company_name):
    """ crawl each google results """
    #try:
    #url = get_linkedin_url(url, copy.deepcopy(s)).replace('cn.linkedin.com', 'www.linkedin.com')  # 百度搜索出的结果是百度跳转链接，要提取出linkedin的链接。
    #print(url)
    if len(url) > 0 and url not in LINKS_FINISHED:
        
        

        failure = 0
        while failure < 10:
            try:
                r = s.get(url, timeout=10)
            except:
                failure += 1
                continue
            if r.status_code == 200:
                #print('Succeed',url)
                f = open(company_name+'.csv', 'a+',encoding='utf-8')
                parse(r.text, url, f)
                with open('search.log','a+') as search_log:
                    search_log.write(url+'\n')
                LINKS_FINISHED.append(url)
                #time.sleep(2)
                break
            else:
                print ('%s %s' % (r.status_code, url))
                failure += 2
        if failure >= 10:
            print ('Failed: %s' % url)
    #except:
        #pass


if __name__ == '__main__':
    # load search log
    if os.path.exists('search.log'):
        search_log_file = open('search.log','r')
        for log in search_log_file.readlines():
            #print(log)
            LINKS_FINISHED.append(log.strip('\n'))
        #print(LINKS_FINISHED)
        search_log_file.close()
    #raise TypeError('123')
    s = login(laccount=laccount, lpassword=lpassword)  # 输入账号
    company_name = input('Input the company you want to crawl:')
    maxpage = 50  # 抓取前50页百度搜索结果，百度搜索最多显示76页

    # google search in www.linkedin.com/in
    # url = 'https://www.google.com/search?newwindow=1&source=hp&ei=SAOCWrrPI6Pm_Qbu657wDA&q='+company_name+'+site%3Awww.linkedin.com%2Fin'
    # url = 'http://www.baidu.com/s?ie=UTF-8&wd=%20%7C%20领英%20' + quote(company_name) + '%20site%3Alinkedin.com'
    url = 'https://www.bing.com/search?q='+company_name+'+site%3Awww.linkedin.com%2Fin'
    print(url)
    results = []
    failure = 0
    while len(url) > 0 and failure < 10:
        try:
            r = requests.get(url, timeout=10)
            #print(r.headers)
        except:
            failure += 1
            continue
        if r.status_code == 200:
            hrefs = list(set(re.findall('https://www\.linkedin\.com/in/[a-z|0-9|-]+', r.text)))  # 一页有10个搜索结果
            for href in hrefs:
                #print(href)
                crawl(href, copy.deepcopy(s), company_name)
            results += hrefs
            tree = etree.HTML(r.content)
            # nextpage_txt = tree.xpath('//td/a/@href')
            # url = 'http://www.google.com' + nextpage_txt[-1].strip() if nextpage_txt else ''
            nextpage_txt = tree.xpath('//li[@class="b_pag"]/nav/ul/li/a/@href')
            url = 'http://www.bing.com' + nextpage_txt[-1].strip() if nextpage_txt else ''
            failure = 0
            maxpage -= 1
            if maxpage <= 0:
                break
        else:
            failure += 2
            print ('search failed: %s' % r.status_code)
    if failure >= 10:
        print ('search failed: %s' % url)
    
