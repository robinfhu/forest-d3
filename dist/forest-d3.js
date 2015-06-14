
/*
********************************************************
Forest D3 - a charting library using d3.js

Author:  Robin Hu

********************************************************
 */

(function() {
  this.ForestD3 = {
    version: '1.0.0'
  };

}).call(this);

(function() {
  this.ForestD3.Utils = (function() {
    var colors20;
    colors20 = d3.scale.category20().range();
    return {

      /*
      Calculates the minimum and maximum point across all series'.
      Useful for setting the domain for a d3.scale()
      
      data: Array of series'
      x: function to get X value
      y: function to get Y value
      
      Returns:
          {
              x: [min, max]
              y: [min, max]
          }
       */
      extent: function(data, x, y) {
        var allPoints, defaultExtent, roundOff, xExt, yExt;
        defaultExtent = [-1, 1];
        if (!data || data.length === 0) {
          return {
            x: defaultExtent,
            y: defaultExtent
          };
        }
        allPoints = data.map(function(series) {
          return series.values;
        });
        allPoints = d3.merge(allPoints);
        if (x == null) {
          x = function(d, i) {
            return d[0];
          };
        }
        if (y == null) {
          y = function(d, i) {
            return d[1];
          };
        }
        xExt = d3.extent(allPoints, x);
        yExt = d3.extent(allPoints, y);
        roundOff = function(d, i) {
          if (i === 0) {
            return Math.floor(d);
          }
          return Math.ceil(d);
        };
        xExt = xExt.map(roundOff);
        yExt = yExt.map(roundOff);
        return {
          x: xExt,
          y: yExt
        };
      },

      /*
      Adds a numeric _index to each series, which is used to uniquely
      identify it.
       */
      indexify: function(data) {
        return data.map(function(d, i) {
          d._index = i;
          return d;
        });
      },
      defaultColor: function(i) {
        return colors20[i % colors20.length];
      }
    };
  })();

}).call(this);

(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  this.ForestD3.DataAPI = function(data) {
    var chart;
    chart = this;
    return {
      get: function() {
        return data;
      },
      displayInfo: function() {
        return data.map(function(d) {
          return {
            key: d.key,
            label: d.label,
            hidden: d.hidden === true,
            color: chart.seriesColor(d)
          };
        });
      },
      hide: function(keys, flag) {
        var d, i, len, ref;
        if (flag == null) {
          flag = true;
        }
        if (!(keys instanceof Array)) {
          keys = [keys];
        }
        for (i = 0, len = data.length; i < len; i++) {
          d = data[i];
          if (ref = d.key, indexOf.call(keys, ref) >= 0) {
            d.hidden = flag;
          }
        }
        return this;
      },
      show: function(keys) {
        return this.hide(keys, false);
      },
      toggle: function(keys) {
        var d, i, len, ref;
        if (!(keys instanceof Array)) {
          keys = [keys];
        }
        for (i = 0, len = data.length; i < len; i++) {
          d = data[i];
          if (ref = d.key, indexOf.call(keys, ref) >= 0) {
            d.hidden = !d.hidden;
          }
        }
        return this;
      },
      showOnly: function(key) {
        var d, i, len;
        for (i = 0, len = data.length; i < len; i++) {
          d = data[i];
          d.hidden = !(d.key === key);
        }
        return this;
      },
      showAll: function() {
        var d, i, len;
        for (i = 0, len = data.length; i < len; i++) {
          d = data[i];
          d.hidden = false;
        }
        return this;
      },
      visible: function() {
        return data.filter(function(d) {
          return !d.hidden;
        });
      },
      render: function() {
        return chart.render();
      }
    };
  };

}).call(this);


/*
Draws a chart legend using HTML.
It acts as a plugin to a main chart instance.
 */

(function() {
  var Legend;

  this.ForestD3.Legend = Legend = (function() {
    function Legend(domContainer) {
      this.name = 'legend';
      if (domContainer.select != null) {
        this.container = domContainer;
      } else {
        this.container = d3.select(domContainer);
      }
      this.container.classed('forest-d3 legend', true);
    }

    Legend.prototype.chart = function(chart) {
      this.chartInstance = chart;
      return this;
    };

    Legend.prototype.render = function() {
      var colorSquares, data, items, labels, onlyButton, showAll;
      if (this.chartInstance == null) {
        return;
      }
      showAll = this.container.selectAll('div.show-all').data([0]);
      showAll.enter().append('div').classed('show-all button', true).text('show all').on('click', (function(_this) {
        return function(d) {
          return _this.chartInstance.data().showAll().render();
        };
      })(this));
      data = this.chartInstance.data().displayInfo();
      items = this.container.selectAll('div.item').data(data, function(d) {
        return d.key;
      });
      items.enter().append('div').classed('item', true);
      items.on('click', (function(_this) {
        return function(d) {
          return _this.chartInstance.data().toggle(d.key).render();
        };
      })(this));
      items.classed('disabled', function(d) {
        return d.hidden;
      });
      colorSquares = items.selectAll('span.color-square').data(function(d) {
        return [d];
      });
      colorSquares.enter().append('span').classed('color-square', true).style('background-color', function(d) {
        return d.color;
      });
      labels = items.selectAll('span.description').data(function(d) {
        return [d];
      });
      labels.enter().append('span').classed('description', true).text(function(d) {
        return d.label;
      });
      onlyButton = items.selectAll('span.show-only').data(function(d) {
        return [d];
      });
      return onlyButton.enter().append('span').classed('show-only button', true).text('only').on('click', (function(_this) {
        return function(d) {
          d3.event.stopPropagation();
          return _this.chartInstance.data().showOnly(d.key).render();
        };
      })(this));
    };

    return Legend;

  })();

}).call(this);

(function() {
  var Chart, chartProperties;

  chartProperties = [
    [
      'getX', function(d, i) {
        return d[0];
      }
    ], [
      'getY', function(d, i) {
        return d[1];
      }
    ], ['autoResize', true], ['color', ForestD3.Utils.defaultColor]
  ];

  this.ForestD3.Chart = Chart = (function() {
    function Chart(domContainer) {
      var defaultVal, j, len, prop, propPair;
      this.properties = {};
      for (j = 0, len = chartProperties.length; j < len; j++) {
        propPair = chartProperties[j];
        prop = propPair[0], defaultVal = propPair[1];
        this.properties[prop] = defaultVal;
        this[prop] = (function(_this) {
          return function(prop) {
            return function(d) {
              if (d == null) {
                return _this.properties[prop];
              } else {
                _this.properties[prop] = d;
                return _this;
              }
            };
          };
        })(this)(prop);
      }
      this.container(domContainer);
      this.xAxis = d3.svg.axis().tickPadding(10);
      this.yAxis = d3.svg.axis().tickPadding(10);
      this.seriesColor = (function(_this) {
        return function(d) {
          return d.color || _this.color()(d._index);
        };
      })(this);
      this.plugins = {};

      /*
      Auto resize the chart if user resizes the browser window.
       */
      window.onresize = (function(_this) {
        return function() {
          if (_this.autoResize()) {
            return _this.render();
          }
        };
      })(this);
    }


    /*
    Set chart data.
     */

    Chart.prototype.data = function(d) {
      if (d == null) {
        return ForestD3.DataAPI.call(this, this.chartData);
      } else {
        d = ForestD3.Utils.indexify(d);
        this.chartData = d;
        return this;
      }
    };

    Chart.prototype.container = function(d) {
      if (d == null) {
        return this.properties['container'];
      } else {
        if (d.select != null) {
          d = d.node();
        }
        this.properties['container'] = d;
        this.svg = this.createSvg();
        return this;
      }
    };


    /*
    Create an <svg> element to start rendering the chart.
     */

    Chart.prototype.createSvg = function() {
      var container, exists;
      container = this.container();
      if (container != null) {
        exists = d3.select(container).classed('forest-d3', true).select('svg');
        if (exists.empty()) {
          return d3.select(container).append('svg');
        } else {
          return exists;
        }
      }
      return null;
    };


    /*
    Main rendering logic.  Here we should update the chart frame, axes
    and series points.
     */

    Chart.prototype.render = function() {
      var chart, seriesGroups;
      if (this.svg == null) {
        return this;
      }
      if (this.chartData == null) {
        return this;
      }
      this.updateDimensions();
      this.updateChartScale();
      this.updateChartFrame();
      seriesGroups = this.canvas.selectAll('g.series').data(this.data().visible(), function(d) {
        return d.key;
      });
      seriesGroups.enter().append('g').attr('class', function(d, i) {
        return "series series-" + (d.key || i);
      });
      seriesGroups.style('fill', this.seriesColor);
      seriesGroups.exit().remove();
      chart = this;
      seriesGroups.each(function(d, i) {
        var points, x, y;
        points = d3.select(this).selectAll('circle.point').data(function(d) {
          return d.values;
        });
        x = chart.getX();
        y = chart.getY();
        points.enter().append('circle').classed('point', true).attr('cx', chart.canvasWidth / 2).attr('cy', chart.canvasHeight / 2).attr('r', 0);
        return points.transition().delay(function(d, i) {
          return i * 10;
        }).ease('quad').attr('cx', function(d, i) {
          return chart.xScale(x(d, i));
        }).attr('cy', function(d, i) {
          return chart.yScale(y(d, i));
        }).attr('r', 7);
      });
      this.renderPlugins();
      return this;
    };


    /*
    Get the chart's dimensions, based on the parent container <div>.
    Calculate chart margins and canvas dimensions.
     */

    Chart.prototype.updateDimensions = function() {
      var bounds, container;
      container = this.container();
      if (container != null) {
        bounds = container.getBoundingClientRect();
        this.height = bounds.height;
        this.width = bounds.width;
        this.margin = {
          left: 80,
          bottom: 50,
          right: 20,
          top: 20
        };
        this.canvasHeight = this.height - this.margin.bottom - this.margin.top;
        return this.canvasWidth = this.width - this.margin.left - this.margin.right;
      }
    };


    /*
    Draws the chart frame. Things like backdrop and canvas.
     */

    Chart.prototype.updateChartFrame = function() {
      var backdrop, xAxisGroup, yAxisGroup;
      backdrop = this.svg.selectAll('rect.backdrop').data([0]);
      backdrop.enter().append('rect').classed('backdrop', true);
      backdrop.attr('width', this.width).attr('height', this.height);
      this.xAxis.scale(this.xScale).tickSize(-this.canvasHeight, 1);
      xAxisGroup = this.svg.selectAll('g.x-axis').data([0]);
      xAxisGroup.enter().append('g').attr('class', 'x-axis axis');
      xAxisGroup.attr('transform', "translate(" + this.margin.left + ", " + (this.canvasHeight + this.margin.top) + ")");
      this.yAxis.scale(this.yScale).orient('left').tickSize(-this.canvasWidth, 1);
      yAxisGroup = this.svg.selectAll('g.y-axis').data([0]);
      yAxisGroup.enter().append('g').attr('class', 'y-axis axis');
      yAxisGroup.attr('transform', "translate(" + this.margin.left + ", " + this.margin.top + ")");
      xAxisGroup.transition().call(this.xAxis);
      yAxisGroup.transition().call(this.yAxis);
      this.canvas = this.svg.selectAll('g.canvas').data([0]);
      this.canvas.enter().append('g').classed('canvas', true).attr('transform', "translate(" + this.margin.left + ", " + this.margin.top + ")").append('rect').classed('canvas-backdrop', true);
      return this.canvas.select('rect.canvas-backdrop').attr('width', this.canvasWidth).attr('height', this.canvasHeight);
    };

    Chart.prototype.updateChartScale = function() {
      var extent;
      extent = ForestD3.Utils.extent(this.data().visible());
      this.yScale = d3.scale.linear().domain(extent.y).range([this.canvasHeight, 0]);
      return this.xScale = d3.scale.linear().domain(extent.x).range([0, this.canvasWidth]);
    };

    Chart.prototype.addPlugin = function(plugin) {
      this.plugins[plugin.name] = plugin;
      return this;
    };

    Chart.prototype.renderPlugins = function() {
      var key, plugin, ref, results;
      ref = this.plugins;
      results = [];
      for (key in ref) {
        plugin = ref[key];
        if (plugin.chart != null) {
          plugin.chart(this);
        }
        if (plugin.render != null) {
          results.push(plugin.render());
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    return Chart;

  })();

}).call(this);