library(shiny)
library(shinythemes)
library(dplyr)
library(ggplot2)
library(plotly)
library(shinymaterial)
library(tidyr)
library(shinydashboard)
library(scales)
library(DT)


# read in the data set

# -------------------------Unemployment load in data------------------------------
rate <- read.csv("../data/unemployment 99-16.csv", header = T)
rate <- rate[,-1]
colnames(rate) <- c("state",seq(1999,2016,1))
# melt data
rate1 <- gather(rate, year, rate, -state)
rate1$hover <- with(rate1, paste("unemployment rate in",state,"is",':<br>', rate))

# give state boundaries a white border
l <- list(color = toRGB("white"), width = 2)
# specify some map projection/options
g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)

# -------------------------Income distribution loadin data------------------------------
dat <- read.csv("../output/dat.csv")
dat_year <- unique(dat$Year)
dat_profession <- unique(dat$OCC_TITLE)
dat_state <- unique(as.character(dat$STATE))

# Income quintile
mean_qt <- unname(quantile(dat$A_MEAN, probs = seq(0, 1, 0.20), na.rm = T))
# Adjusted quintile
adj_qt <- unname(quantile(dat$A_ADJ, probs = seq(0, 1, 0.20), na.rm = T))

# Adjusted income quintile
dat$A_MEAN_QT <- rep(NA, nrow(dat))
for (i in 1:nrow(dat)){
  if (is.na(dat$A_MEAN[i])) {
    dat$A_MEAN_QT[i] <- NA  
  }
  else if (dat$A_MEAN[i] <= mean_qt[1]){
    dat$A_MEAN_QT[i] <- 0.20
  } else if( dat$A_MEAN[i] > mean_qt[1] & dat$A_MEAN[i] <= mean_qt[2]){
    dat$A_MEAN_QT[i] <- 0.40
  } else if (dat$A_MEAN[i] > mean_qt[2] & dat$A_MEAN[i] <= mean_qt[3]  ){
    dat$A_MEAN_QT[i] <- 0.60
  } else if (dat$A_MEAN[i] > mean_qt[3] & dat$A_MEAN[i] <= mean_qt[4]  ){
    dat$A_MEAN_QT[i] <- 0.80
  } else {(dat$A_MEAN[i] > mean_qt[4] & dat$A_MEAN[i] <= mean_qt[5]  )
    dat$A_MEAN_QT[i] <- 1
  } 
}

# Adjusted income quintile percent
dat$A_MEAN_QT_P <- rep(NA, nrow(dat))
for (i in 1:nrow(dat)){
  if (is.na(dat$A_MEAN[i])) {
    dat$A_MEAN_QT[i] <- NA  
  }
  else if (dat$A_MEAN_QT[i] == "0.2"){
    dat$A_MEAN_QT_P[i] <- "Lowest quintile"
  } else if( dat$A_MEAN_QT[i] == "0.4"){
    dat$A_MEAN_QT_P[i] <- "Fourth quintile"
  } else if (dat$A_MEAN_QT[i] == "0.6"  ){
    dat$A_MEAN_QT_P[i] <- "Third quintile"
  } else if (dat$A_MEAN_QT[i] == "0.8"   ){
    dat$A_MEAN_QT_P[i] <- "Second quintile"
  } else if (dat$A_MEAN_QT[i] == "1"){
    dat$A_MEAN_QT_P[i] <- "Highest quintile"
  }
}

# Adjusted income quintile
dat$A_ADJ_QT <- rep(NA, nrow(dat))
for (i in 1:nrow(dat)){
  if (is.na(dat$A_ADJ[i])) {
    dat$A_ADJ_QT[i] <- NA  
  }
  else if (dat$A_ADJ[i] <= mean_qt[1]){
    dat$A_ADJ_QT[i] <- 0.20
  } else if( dat$A_ADJ[i] > mean_qt[1] & dat$A_ADJ[i] <= mean_qt[2]){
    dat$A_ADJ_QT[i] <- 0.40
  } else if (dat$A_ADJ[i] > mean_qt[2] & dat$A_ADJ[i] <= mean_qt[3]  ){
    dat$A_ADJ_QT[i] <- 0.60
  } else if (dat$A_ADJ[i] > mean_qt[3] & dat$A_ADJ[i] <= mean_qt[4]  ){
    dat$A_ADJ_QT[i] <- 0.80
  } else {(dat$A_ADJ[i] > mean_qt[4] & dat$A_ADJ[i] <= mean_qt[5]  )
    dat$A_ADJ_QT[i] <- 1
  } 
}

# Adjusted income quintile percent
dat$A_ADJ_QT_P <- rep(NA, nrow(dat))
for (i in 1:nrow(dat)){
  if (is.na(dat$A_ADJ[i])) {
    dat$A_ADJ_QT[i] <- NA  
  }
  else if (dat$A_ADJ_QT[i] == "0.2"){
    dat$A_ADJ_QT_P[i] <- "Lowest quintile"
  } else if( dat$A_ADJ_QT[i] == "0.4"){
    dat$A_ADJ_QT_P[i] <- "Fourth quintile"
  } else if (dat$A_ADJ_QT[i] == "0.6"  ){
    dat$A_ADJ_QT_P[i] <- "Third quintile"
  } else if (dat$A_ADJ_QT[i] == "0.8"   ){
    dat$A_ADJ_QT_P[i] <- "Second quintile"
  } else if (dat$A_ADJ_QT[i] == "1"){
    dat$A_ADJ_QT_P[i] <- "Highest quintile"
  }
}

# hover
dat$hover <- with(dat, paste(STATE, '<br>', "Income Quintile:", A_MEAN_QT_P,
                             '<br>', "Adjusted Income Quintile:", A_ADJ_QT_P))


l1 <- list(color = toRGB("white"), width = 2)
g1 <- list(scope = 'usa',
           projection = list(type = 'albers usa'),
           showlakes = TRUE,
           lakecolor = toRGB('white')
)

dat$INC <- "Average Income"
dat$AD_INC <- "Adjusted Average Income"

# -------------------------Job distribution load in data------------------------------
rsh <- read.csv('../output/columbia statistics 2012-2017 processed3.csv')
rsh <- rsh[,-1]
stata.data <- c('AZ','CA','MA','NJ','NY','TX','WA','IL','NC','GA','OH','RI')
rsh$job_location <- factor(rsh$job_location)
rsh$job_title <- factor(rsh$job_title)
job.data <- as.vector(unique(rsh$job_title))
rsh1 <- c(NA,NA,NA)
for(i in stata.data){
  rsh.sub <- rsh[which(rsh$job_location==i),]
  for(j in job.data){
    row <- cbind(state = i, job =j, number = length(which(rsh.sub$job_title == j)))
    if(row[3] !=0){
      rsh1 <- rbind(rsh1, row)
    }
  }
}
rsh1 <- rsh1[-1,]
rsh1 <- as.data.frame(rsh1)

# -------------------------Job distribution load in data------------------------------
place <- read.csv("../output/place.csv")
people <- read.csv("../output/people.csv")

# map projection
geo <- list(
  scope = 'world',
  #  projection = list(type = 'equirectangular'),
  projection = list(type = 'orthographic'),
  showland = TRUE,
  showlakes = TRUE,
  showcountries = TRUE,
  showocean = TRUE,
  showsubunits = TRUE,
  oceancolor = toRGB("#ABD0D3"),
  lakecolor = toRGB("white"),
  landcolor = toRGB("#FFFBF0"),
  countrycolor = toRGB("#D4AFD7"),
  subunitcolor = toRGB("black")
)

# User Interface
ui <- material_page(
  title = strong("Where did Columbia Alumni go?"),
  color = "red",
  nav_bar_fixed = FALSE,
  
  # Place side-nav in the beginning of the UI
  material_side_nav(
    fixed = F,
    # Place side-nav tabs within side-nav
    material_side_nav_tabs(
      side_nav_tabs = c(
        "Home" = "example_side_nav_tab_1",
        "US Unemployment" = "example_side_nav_tab_2",
        "Income Distribution" = "example_side_nav_tab_3",
        "Job Distribution" = "example_side_nav_tab_4"
      ),
      icons = c("cast", "insert_chart","cast","insert_chart")
    )
  ),
  
  
  
  # Introduction Tab
  material_side_nav_tab_content(
    side_nav_tab_id = "example_side_nav_tab_1",
    tags$h1("  Introduction"),
    
    # Parallax
    material_parallax(
      image_source = "https://4.bp.blogspot.com/-_bjMhQf3KxY/WoiwWLSh7HI/AAAAAAAAAOU/PX59obSEdRA8wa7XTN78jOC7ve_sLU7ngCLcBGAs/s1600/Graduates-header.jpg"
    ),
    tags$h5('  Career path is often the hardest decision to make as a student. In this project, we provided the job distribution, company name, and job location of the former 
            M.A. students in Statistics at Columbia University as well as the average income and unemployment rate in each state aiming to provide current students more 
            options in choosing their future career path.')
    ),
  
  # -------------------------Unemployment Tab------------------------------
  material_side_nav_tab_content(
    side_nav_tab_id = "example_side_nav_tab_2",
    material_row(
      material_column(
        width = 6,
        material_card(
          depth = 4, sliderInput("yearInput", "Year", 1999 , 2016, 1999)
        )
      ),
      
      material_column(
        width = 6,
        material_card(
          depth = 4,
          selectizeInput("stateInput1", "Please enter a state name", unique(rate1$state), selected = "NY", multiple = T,
                         options = list(maxOptions = 5, placeholder = 'Please enter a state name')),
          material_switch("checkInput","Include US Rate", on_label = "on", off_label = "off", initial_value = F)
        )
      )
    ),
    
    material_row(
      material_column(
        width = 6,
        material_card(
          depth = 4, plotlyOutput("map",width = "100%")
        )
      ),
      material_column(
        width = 6,
        material_card(
          depth = 4, plotOutput("lineplot", width = "100%")
        )
      )
    )
  ),
  
  # -------------------------Income Tab------------------------------
  material_side_nav_tab_content(
    side_nav_tab_id = "example_side_nav_tab_3",
    material_row(
      material_column(
        width = 4,
        depth = 4, 
        selectInput("yearInput1",label = "Year", choices = dat_year, selected = "2014")
      ),
      material_column(
        width = 4,
        depth = 4, 
        selectInput(inputId = "occInput",label = "Profession", choices = dat_profession, selected = "Statisticians")
      ),
      material_column(
        width = 4,
        depth = 4, 
        selectInput(inputId = "incInput3",label = "Income", choices = c("Average Income", "Adjusted Average Income"), selected = "Average Income")
      )
    ),
    
    material_row(
      width = 12,
      material_card(
        title = "Heatmap of Average Income",
        depth = 4,
        plotlyOutput("plot2")
      )
    ),
    
    material_row(
      width = 12,
      material_card(
        title = "Barplot of Income by State",
        depth = 4,
        plotlyOutput("plot3", width = "100%", height = 1000)
      )
    )
  ),
  
  # -------------------------Job Distribution Tab------------------------------
  material_side_nav_tab_content(
    side_nav_tab_id = "example_side_nav_tab_4",
    material_tabs(
      tabs = c(
        "3D Map" = "first_tab",
        "Job Placement" = "second_tab"
      )
    ),
    material_tab_content(
      tab_id = "second_tab",
      material_row(
        material_column(
          width = 2,
          material_card(
            depth = 4,
            selectInput('stateInput','Choose a state:', choices = stata.data, selected = 'NY'),
            selectInput('jobInput', 'Choose a job title', choices = job.data, selected = 'Software')
          )
        ),
        material_column(
          width = 5,
          material_card(
            depth = 4,
            # output
            plotlyOutput("plot", width = "100%")
          )
        ),
        material_column(
          width = 5,
          material_card(
            depth = 4,
            # output
            plotlyOutput("plot1", width = "100%")
          )
        ),
        material_column(
          width = 12,
          material_card(
            depth = 4,
            tabsetPanel(
              tabPanel('Company Name by State',DT::dataTableOutput("mytable1"))
              # tabPanel('Company Name by Job Title',DT::dataTableOutput("mytable2")),
              # tabPanel('Company Name by Job Title and State',DT::dataTableOutput("mytable3"))
            )
          )
        )
      )
    ),
    material_tab_content(
      tab_id = "first_tab",
      material_row(
        material_column(
          width = 12,
          selectInput('majorInput','Choose a major:', choices = c("Both included", "Statistics", "Computer Science")
                      , selected = 'Statistics')
        )
      ),
      
      material_row(
        material_column(
          width = 12,
          plotlyOutput("geomap", width = "100%", height = "700px", inline = T)
        )
      )
    )
  )
    )

# Server
server <- function(input, output, session) {
  # -------------------------Unemployment------------------------------
  unemploy_a <- reactive({
    req(input$yearInput)
    rate1 %>% filter_(~ year == input$yearInput)
  })
  
  output$map <- renderPlotly({
    # spinner
    material_spinner_show(session, "map")
    Sys.sleep(time = 0.3)
    material_spinner_hide(session, "map")
    #heatmap
    plot_ly(unemploy_a(), z = ~rate, text = ~hover, locations = ~state, type = 'choropleth',
            locationmode = 'USA-states', color = ~rate, colors = 'Reds',
            marker = ~list(line = l), colorbar = list(title = "percentage")) %>%
      layout(title = '1999 to 2016 mean US unemployment rate by state', geo = g)
  })
  output$lineplot <- renderPlot({
    data1 <- rate1 %>% filter_(~state %in% input$stateInput1)
    data2 <- rate1 %>% group_by(year) %>% summarise(mean = mean(rate))
    mean <- rate1 %>% group_by(year) %>% summarise(mean = mean(rate)) %>% select(mean)
    # spinner
    material_spinner_show(session, "lineplot")
    Sys.sleep(time = 0.3)
    material_spinner_hide(session, "lineplot")
    
    ggplot() +
      geom_line(data=data1, aes(x=year, y=rate, group = state, color = state)) +
      {if(input$checkInput) geom_line(data = data2, aes(x = year, y = mean, group = 1, size='qsec'))}
  })
  
  # -------------------------Income------------------------------
  filtered1 <- reactive({
    dat %>%
      filter_(~Year == input$yearInput1,
              ~OCC_TITLE == input$occInput) %>%
      arrange_(~A_MEAN)})
  
  
  filtered2 <- reactive({
    dat %>%
      filter_(~Year == input$yearInput1,
              ~OCC_TITLE == input$occInput) %>%
      arrange_(~A_ADJ)  
  })
  
  filtered3 <- reactive({
    dat %>%
      filter_(~Year == input$yearInput1,
              ~OCC_TITLE == input$occInput,
              ~INC == input$incInput3) %>%
      arrange_(~A_MEAN)})
  
  
  filtered4 <- reactive({
    dat %>%
      filter_(~Year == input$yearInput1,
              ~OCC_TITLE == input$occInput,
              ~AD_INC == input$incInput3) %>%
      arrange_(~A_ADJ)})
  
  output$plot2 <- renderPlotly({
    p3 <- plot_ly(filtered3(), z = ~A_MEAN, locations = ~ST,
                  text = ~hover,
                  type = 'choropleth',
                  color = ~A_MEAN,
                  colors = 'Blues',
                  marker = list(colorbar = list(title = "Average Income")),
                  locationmode = 'USA-states')%>%
      layout(geo = g1)
    
    p4 <- plot_ly(filtered4(), z = ~A_ADJ, locations = ~ST,
                  text = ~hover,
                  type = 'choropleth',
                  color = ~A_ADJ,
                  colors = 'Blues',
                  marker = list(colorbar = list(title = "Adjusted Average Income")),
                  locationmode = 'USA-states')%>%
      layout(geo = g1)
    subplot(p3,p4,nrows =1)
  })
  
  output$plot3 <- renderPlotly({
    
    material_spinner_show(session, "map")
    Sys.sleep(time = 0.3)
    material_spinner_hide(session, "map")
    
    p1 <- plot_ly(filtered1(), x = as.numeric(filtered1()$A_MEAN), 
                  y = factor(filtered1()$STATE, 
                             levels = unique(filtered1()$STATE)[order(as.numeric(filtered1()$A_MEAN), 
                                                                      decreasing = TRUE)]), 
                  type = 'bar', name = 'Average Income',
                  marker = list(color = filtered1()$A_MEAN, showscale =FALSE)) %>%
      layout(yaxis = list(autorange = "reversed", dtick = 1))
    
    p2 <- plot_ly(filtered2(), x = as.numeric(filtered2()$A_ADJ), 
                  y = factor(filtered2()$STATE, 
                             levels = unique(filtered2()$STATE)[order(as.numeric(filtered2()$A_ADJ), 
                                                                      decreasing = TRUE)]), 
                  type = 'bar', name = 'Adjusted Average Income',
                  marker = list(color = filtered2()$A_ADJ, showscale =FALSE)) %>%
      layout(xaxis = list(autorange = "reversed",side="right", showgrid=FALSE),
             yaxis = list(autorange = "reversed",side="right", showgrid=FALSE, dtick = 1))
    
    subplot(p1,p2, nrows =1)
  })
  
  # -------------------------Job Distribution------------------------------
  unemploy <- reactive({
    rsh1 %>% filter_(~state == input$stateInput)
  })
  unemploy3 <- reactive({
    rsh1 %>% filter_(~job == input$jobInput)
  })
  unemploy1 <- reactive({
    rsh[,c("company_most_recent", "job_title","job_location")] %>% filter_(~job_location == input$stateInput)
  })
  
  output$plot <- renderPlotly({
    plot_ly(unemploy(), labels = ~job, values = ~number, type = 'pie',
            textposition = 'inside',
            textinfo = 'label+percent',
            insidetextfont = list(color = '#FFFFFF'),
            hoverinfo = 'text',
            text = ~paste(number, 'alumni work as a', job, 'in', state),
            marker = list(colors = colors,
                          line = list(color = '#FFFFFF', width = 1)),
            #The 'pull' attribute can also be used to create space between the sectors
            showlegend = FALSE) %>%
      layout(title = 'Job Distribution by State',
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    
  })
  output$plot1 <- renderPlotly({
    plot_ly(unemploy3(), labels = ~state, values = ~number, type = 'pie',
            textposition = 'inside',
            textinfo = 'label+percent',
            insidetextfont = list(color = '#FFFFFF'),
            hoverinfo = 'text',
            text = ~paste(number, 'alumni work as a', job, 'in', state),
            marker = list(colors = colors,
                          line = list(color = '#FFFFFF', width = 1)),
            #The 'pull' attribute can also be used to create space between the sectors
            showlegend = FALSE) %>%
      layout(title = 'Job Distribution by job title',
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    
  })
  
  output$mytable1 <- DT::renderDataTable({
    DT::datatable(unemploy1())
  })
  
  people.out <- reactive({
    people %>% filter_(~ major == input$majorInput)
  })
  place.out <- reactive({
    place %>% filter_(~ major == input$majorInput)
  })
  
  output$geomap <- renderPlotly({
    
    plot_geo(color = I("red")) %>%
      add_markers(
        data = place.out(), x = ~ long, y = ~ lat, text = ~ area_and_num,
        size = ~3*count, alpha = 0.5
      ) %>%
      add_segments(
        data = group_by_(people.out(), ~ X),
        x = ~start_long, xend = ~end_long,
        y = ~start_lat, yend = ~end_lat,
        alpha = 0.3, size = I(2), hoverinfo = "none"
      ) %>%
      layout(
        title = 'Job destination',
        geo = geo, showlegend = FALSE
      )
    
  })
}

shinyApp(ui = ui, server = server)
