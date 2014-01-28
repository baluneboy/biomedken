#!/usr/bin/env python

from pims.database.pimsquery import CoordQueryAsDataFrame

_PREAMBLE = """<html>
  <head>
    <!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">

      // Load the Visualization API and the timeline package.
      google.load('visualization', '1.0', {'packages':['timeline']});

      // Set a callback to run when the Google Visualization API is loaded.
      google.setOnLoadCallback(drawChart);

      // Callback that creates and populates a data table,
      // instantiates the timeline chart, passes in the data
      // and draws it.
      function drawChart() {
        var container = document.getElementById('example');
        var chart = new google.visualization.Timeline(container);
        var dataTable = new google.visualization.DataTable();
        dataTable.addColumn({ type: 'string', id: 'Sensor' });
        dataTable.addColumn({ type: 'string', id: 'Name' });
        dataTable.addColumn({ type: 'date', id: 'Start' });
        dataTable.addColumn({ type: 'date', id: 'End' });
        dataTable.addRows(["""

_EPILOGUE = """        ]);

        var options = {
          timeline: { colorByRowLabel: false },
          backgroundColor: '#FFF',
          //colors: ['#003380', '#0066FF', '#003380', '#007A00', '#FF5C33', '#991F00'],
        };

        chart.draw(dataTable, options);
      }
</script>
  </head>

  <body>
    <!--Div that will hold the timeline chart-->
    <div id="example" style="height: 900px;"></div>
  </body>
</html>"""

def main():
    c = CoordQueryAsDataFrame(host='localhost')
    c.filter_dataframe_sensors('^121f0|^es0|hirap')
    c.filter_pre2001()
    c.consolidate_rpy_xyz()
    #print c.dataframe
    sensor_rows = c.get_rows()
    print _PREAMBLE
    print sensor_rows
    print _EPILOGUE
    
if __name__ == "__main__":
    main()
    