
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

  this.ForestD3.ChartItem = {};

}).call(this);

(function() {
  var BaseChart;

  this.ForestD3.BaseChart = BaseChart = (function() {
    function BaseChart(domContainer) {
      this.properties = {};
      this.container(domContainer);
      this._metadata = {};
      this._dispatch = d3.dispatch('rendered', 'stateUpdate');
      this.plugins = {};

      /*
      Auto resize the chart if user resizes the browser window.
       */
      this.resize = (function(_this) {
        return function() {
          if (_this.autoResize()) {
            return _this.render();
          }
        };
      })(this);
      window.addEventListener('resize', this.resize);
      this._attachStateHandlers();
    }


    /*
    Call this method to remove chart from the document and any artifacts
    it has (like tooltips) and event handlers.
     */

    BaseChart.prototype.destroy = function() {
      var domContainer;
      domContainer = this.container();
      if ((domContainer != null ? domContainer.parentNode : void 0) != null) {
        domContainer.parentNode.removeChild(domContainer);
      }
      return window.removeEventListener('resize', this.resize);
    };

    BaseChart.prototype.metadata = function(d) {
      if (typeof d === 'string') {
        return this._metadata[d];
      } else if (typeof d === 'object' && (d.key != null)) {
        return this._metadata[d.key];
      } else {
        return this._metadata;
      }
    };

    BaseChart.prototype.on = function(type, listener) {
      return this._dispatch.on(type, listener);
    };

    BaseChart.prototype.trigger = function(type) {
      return this._dispatch[type].apply(this, Array.prototype.slice.call(arguments, 1));
    };

    BaseChart.prototype._attachStateHandlers = function() {
      return this.on('stateUpdate', (function(_this) {
        return function(state) {
          var attr, config, key, meta, results, val;
          results = [];
          for (key in state) {
            config = state[key];
            meta = _this.metadata()[key];
            if (meta != null) {
              results.push((function() {
                var results1;
                results1 = [];
                for (attr in config) {
                  val = config[attr];
                  results1.push(meta[attr] = val);
                }
                return results1;
              })());
            } else {
              results.push(void 0);
            }
          }
          return results;
        };
      })(this));
    };

    BaseChart.prototype.container = function(d) {
      if (d == null) {
        return this.properties['container'];
      } else {
        if ((d.select != null) && (d.node != null)) {
          d = d.node();
        } else if (typeof d === 'string') {
          d = document.querySelector(d);
        }
        this.properties['container'] = d;
        this.svg = this.createSvg();
        return this;
      }
    };


    /*
    Create an <svg> element to start rendering the chart.
     */

    BaseChart.prototype.createSvg = function() {
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

    BaseChart.prototype._setProperties = function(chartProperties) {
      var defaultVal, i, len, prop, propPair, results;
      results = [];
      for (i = 0, len = chartProperties.length; i < len; i++) {
        propPair = chartProperties[i];
        prop = propPair[0], defaultVal = propPair[1];
        this.properties[prop] = defaultVal;
        results.push(this[prop] = (function(_this) {
          return function(prop) {
            return function(d) {
              if (typeof d === 'undefined') {
                return _this.properties[prop];
              } else {
                _this.properties[prop] = d;
                return _this;
              }
            };
          };
        })(this)(prop));
      }
      return results;
    };

    return BaseChart;

  })();

}).call(this);

(function() {
  this.ForestD3.ChartItem.bar = function(selection, selectionData) {
    var barBase, barCount, barIndex, barWidth, bars, chart, fullSpace, maxFullSpace, maxPadding, x, xCentered, y;
    chart = this;
    bars = selection.selectAll('rect.bar').data(selectionData.values);
    x = chart.getXInternal();
    y = chart.getY();

    /*
    Ensure the bars are based at the zero line, but does not extend past
    canvas boundaries.
     */
    barBase = chart.yScale(0);
    if (barBase > chart.canvasHeight) {
      barBase = chart.canvasHeight;
    } else if (barBase < 0) {
      barBase = 0;
    }
    fullSpace = chart.canvasWidth / selectionData.values.length;
    barCount = chart.data().barCount();
    maxFullSpace = chart.xScale(1) / 2;
    fullSpace = d3.min([maxFullSpace, fullSpace]);
    maxPadding = 15;
    fullSpace -= d3.min([fullSpace * 0.1, maxPadding]);
    fullSpace = d3.max([barCount, fullSpace]);

    /*
    This is used to ensure that the bar group is centered around the x-axis
    tick mark.
     */
    xCentered = fullSpace / 2;
    bars.enter().append('rect').classed('bar', true).attr('x', function(d, i) {
      return chart.xScale(x(d, i)) - xCentered;
    }).attr('y', barBase).attr('height', 0);
    bars.exit().remove();
    barIndex = chart.data().barIndex(selectionData.key);
    barWidth = fullSpace / barCount;
    return bars.transition().duration(selectionData.duration || chart.duration()).delay(function(d, i) {
      return i * 20;
    }).attr('x', function(d, i) {

      /*
      Calculates the x position of each bar. Shifts the bar along x-axis
      depending on which series index the bar belongs to.
       */
      return chart.xScale(x(d, i)) - xCentered + barWidth * barIndex;
    }).attr('y', function(d, i) {
      var yVal;
      yVal = y(d, i);
      if (yVal < 0) {
        return barBase;
      } else {
        return chart.yScale(y(d, i));
      }
    }).attr('height', function(d, i) {
      return Math.abs(chart.yScale(y(d, i)) - barBase);
    }).attr('width', barWidth).style('fill', chart.seriesColor(selectionData));
  };

}).call(this);


/*
Draws a simple line graph.
If you set area=true, turns it into an area graph
 */

(function() {
  this.ForestD3.ChartItem.line = function(selection, selectionData) {
    var area, areaBase, areaFn, chart, duration, interpolate, lineFn, path, x, y;
    chart = this;
    selection.style('stroke', chart.seriesColor);
    interpolate = selectionData.interpolate || 'linear';
    x = chart.getXInternal();
    y = chart.getY();
    lineFn = d3.svg.line().interpolate(interpolate).x(function(d, i) {
      return chart.xScale(x(d, i));
    });
    path = selection.selectAll('path.line').data([selectionData.values]);
    path.enter().append('path').classed('line', true).attr('d', lineFn.y(chart.canvasHeight));
    duration = selectionData.duration || chart.duration();
    path.transition().duration(duration).attr('d', lineFn.y(function(d, i) {
      return chart.yScale(y(d, i));
    }));
    if (selectionData.area) {
      areaBase = chart.yScale(0);
      if (areaBase > chart.canvasHeight) {
        areaBase = chart.canvasHeight;
      } else if (areaBase < 0) {
        areaBase = 0;
      }
      areaFn = d3.svg.area().interpolate(interpolate).x(function(d, i) {
        return chart.xScale(x(d, i));
      }).y0(areaBase);
      area = selection.selectAll('path.area').data([selectionData.values]);
      area.enter().append('path').classed('area', true).attr('d', areaFn.y1(areaBase));
      return area.transition().duration(duration).style('fill', chart.seriesColor(selectionData)).attr('d', areaFn.y1(function(d, i) {
        return chart.yScale(y(d, i));
      }));
    }
  };

}).call(this);


/*
Draws a horizontal or vertical line at the specified x or y location.
 */

(function() {
  this.ForestD3.ChartItem.markerLine = function(selection, selectionData) {
    var chart, duration, label, labelEnter, labelOffset, labelPadding, labelRotate, line, x, y;
    chart = this;
    line = selection.selectAll('line.marker').data(function(d) {
      return [d.value];
    });
    label = selection.selectAll('text.marker-label').data([selectionData.label]);
    labelEnter = label.enter().append('text').classed('marker-label', true).text(function(d) {
      return d;
    }).attr('x', 0).attr('y', 0);
    labelPadding = 10;
    duration = selectionData.duration || chart.duration();
    if (selectionData.axis === 'x') {
      x = chart.xScale(selectionData.value);
      line.enter().append('line').classed('marker', true).attr('x1', 0).attr('x2', 0).attr('y1', 0);
      line.attr('y2', chart.canvasHeight).transition().duration(duration).attr('x1', x).attr('x2', x);
      labelRotate = "rotate(-90 " + x + " " + chart.canvasHeight + ")";
      labelOffset = "translate(0 " + (-labelPadding) + ")";
      labelEnter.attr('transform', labelRotate);
      return label.attr('y', chart.canvasHeight).transition().duration(duration).attr('transform', labelRotate + " " + labelOffset).attr('x', x);
    } else {
      y = chart.yScale(selectionData.value);
      line.enter().append('line').classed('marker', true).attr('x1', 0).attr('y1', 0).attr('y2', 0);
      line.attr('x2', chart.canvasWidth).transition().duration(duration).attr('y1', y).attr('y2', y);
      return label.attr('text-anchor', 'end').transition().duration(duration).attr('x', chart.canvasWidth).attr('y', y + labelPadding);
    }
  };

}).call(this);

(function() {
  this.ForestD3.ChartItem.ohlc = function(selection, selectionData) {
    var chart, close, closeMarks, duration, hi, lo, open, openMarks, rangeLines, x;
    chart = this;
    selection.classed('ohlc', true);
    rangeLines = selection.selectAll('line.ohlc-range').data(selectionData.values);
    x = chart.getXInternal();
    open = selectionData.getOpen || function(d, i) {
      return d[1];
    };
    hi = selectionData.getHi || function(d, i) {
      return d[2];
    };
    lo = selectionData.getLo || function(d, i) {
      return d[3];
    };
    close = selectionData.getClose || function(d, i) {
      return d[4];
    };
    duration = selectionData.duration || chart.duration();
    rangeLines.enter().append('line').classed('ohlc-range', true).attr('x1', function(d, i) {
      return chart.xScale(x(d, i));
    }).attr('x2', function(d, i) {
      return chart.xScale(x(d, i));
    }).attr('y1', 0).attr('y2', 0);
    rangeLines.exit().remove();
    rangeLines.transition().duration(duration).delay(function(d, i) {
      return i * 20;
    }).attr('x1', function(d, i) {
      return chart.xScale(x(d, i));
    }).attr('x2', function(d, i) {
      return chart.xScale(x(d, i));
    }).attr('y1', function(d, i) {
      return chart.yScale(hi(d, i));
    }).attr('y2', function(d, i) {
      return chart.yScale(lo(d, i));
    });
    openMarks = selection.selectAll('line.ohlc-open').data(selectionData.values);
    openMarks.enter().append('line').classed('ohlc-open', true).attr('y1', 0).attr('y2', 0);
    openMarks.exit().remove();
    openMarks.transition().duration(duration).delay(function(d, i) {
      return i * 20;
    }).attr('y1', function(d, i) {
      return chart.yScale(open(d, i));
    }).attr('y2', function(d, i) {
      return chart.yScale(open(d, i));
    }).attr('x1', function(d, i) {
      return chart.xScale(x(d, i));
    }).attr('x2', function(d, i) {
      return chart.xScale(x(d, i)) - 5;
    });
    closeMarks = selection.selectAll('line.ohlc-close').data(selectionData.values);
    closeMarks.enter().append('line').classed('ohlc-close', true).attr('y1', 0).attr('y2', 0);
    closeMarks.exit().remove();
    return closeMarks.transition().duration(duration).delay(function(d, i) {
      return i * 20;
    }).attr('y1', function(d, i) {
      return chart.yScale(close(d, i));
    }).attr('y2', function(d, i) {
      return chart.yScale(close(d, i));
    }).attr('x1', function(d, i) {
      return chart.xScale(x(d, i));
    }).attr('x2', function(d, i) {
      return chart.xScale(x(d, i)) + 5;
    });
  };

}).call(this);


/*
Draws a transparent rectangle across the canvas signifying an important
region.
 */

(function() {
  this.ForestD3.ChartItem.region = function(selection, selectionData) {
    var chart, duration, end, height, region, regionEnter, start, width, x, y;
    chart = this;
    region = selection.selectAll('rect.region').data([selectionData]);
    regionEnter = region.enter().append('rect').classed('region', true);
    start = d3.min(selectionData.values);
    end = d3.max(selectionData.values);
    duration = selectionData.duration || chart.duration();
    if (selectionData.axis === 'x') {
      x = chart.xScale(start);
      width = Math.abs(chart.xScale(start) - chart.xScale(end));
      regionEnter.attr('width', 0);
      return region.attr('x', x).attr('y', 0).attr('height', chart.canvasHeight).transition().duration(duration).attr('width', width);
    } else {
      y = chart.yScale(end);
      height = Math.abs(chart.yScale(start) - chart.yScale(end));
      regionEnter.attr('height', 0);
      return region.attr('x', 0).attr('y', y).transition().duration(duration).attr('width', chart.canvasWidth).attr('height', height);
    }
  };

}).call(this);


/*
Function responsible for rendering a scatter plot inside a d3 selection.
Must have reference to a chart instance.

Example call: ForestD3.ChartItem.scatter.call chartInstance, d3.select(this)
 */

(function() {
  this.ForestD3.ChartItem.scatter = function(selection, selectionData) {
    var all, chart, points, seriesIndex, shape, symbol, x, y;
    chart = this;
    selection.style('fill', chart.seriesColor);
    points = selection.selectAll('path.point').data(function(d) {
      return d.values;
    });
    x = chart.getXInternal();
    y = chart.getY();
    all = d3.svg.symbolTypes;
    seriesIndex = chart.metadata(selectionData).index;
    shape = selectionData.shape || all[seriesIndex % all.length];
    symbol = d3.svg.symbol().type(shape);
    points.enter().append('path').classed('point', true).attr('transform', "translate(" + (chart.canvasWidth / 2) + "," + (chart.canvasHeight / 2) + ")").attr('d', symbol.size(0));
    points.exit().remove();
    return points.transition().duration(selectionData.duration || chart.duration()).delay(function(d, i) {
      return i * 10;
    }).ease('quad').attr('transform', function(d, i) {
      return "translate(" + (chart.xScale(x(d, i))) + "," + (chart.yScale(y(d, i))) + ")";
    }).attr('d', symbol.size(selectionData.size || 96));
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
      force: values to force onto domains. Example: {y: [0]},
          force 0 onto y domain.
      
      Returns:
          {
              x: [min, max]
              y: [min, max]
          }
       */
      extent: function(data, x, y, force) {
        var defaultExtent, roundOff, xAllPoints, xExt, yAllPoints, yExt;
        defaultExtent = [-1, 1];
        if (!data || data.length === 0) {
          return {
            x: defaultExtent,
            y: defaultExtent
          };
        }
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
        if (force == null) {
          force = {};
        }
        if (force.x == null) {
          force.x = [];
        }
        if (force.y == null) {
          force.y = [];
        }
        if (!(force.x instanceof Array)) {
          force.x = [force.x];
        }
        if (!(force.y instanceof Array)) {
          force.y = [force.y];
        }
        xAllPoints = data.map(function(series) {
          if ((series.values != null) && series.type !== 'region') {
            return d3.extent(series.values, x);
          } else {
            return [];
          }
        });
        yAllPoints = data.map(function(series) {
          if ((series.values != null) && series.type !== 'region') {
            return d3.extent(series.values, y);
          } else {
            return [];
          }
        });
        xExt = d3.extent(d3.merge(xAllPoints));
        yExt = d3.extent(d3.merge(yAllPoints));
        data.filter(function(d) {
          return d.type === 'marker';
        }).forEach(function(marker) {
          if (marker.axis === 'x') {
            return xExt.push(marker.value);
          } else {
            return yExt.push(marker.value);
          }
        });
        data.filter(function(d) {
          return d.type === 'region';
        }).forEach(function(region) {
          if (region.axis === 'x') {
            return xExt = xExt.concat(region.values);
          } else {
            return yExt = yExt.concat(region.values);
          }
        });
        xExt = xExt.concat(force.x);
        yExt = yExt.concat(force.y);
        xExt = d3.extent(xExt);
        yExt = d3.extent(yExt);
        roundOff = function(d, i) {
          if (Math.abs(d) < 1) {
            return d;
          }
          if (i === 0) {
            if (isNaN(d)) {
              return -1;
            } else {
              return Math.floor(d);
            }
          } else {
            if (isNaN(d)) {
              return 1;
            } else {
              return Math.ceil(d);
            }
          }
        };
        xExt = xExt.map(roundOff);
        yExt = yExt.map(roundOff);
        return {
          x: xExt,
          y: yExt
        };
      },

      /*
      Increases an extent by a certain percentage. Useful for padding the
      edges of a chart so the points are not right against the axis.
      
      extent: Object of form:
          {
              x: [-10, 10]
              y: [-1, 1]
          }
      
      padding: Object of form:
          {
              x: 0.1    # percentage to pad by
              y: 0.05
          }
       */
      extentPadding: function(extent, padding) {
        var amount, domain, key, padPercent, range, result;
        result = {};
        for (key in extent) {
          domain = extent[key];
          padPercent = padding[key];
          if (padPercent != null) {
            if (domain[0] === 0 && domain[1] === 0) {
              result[key] = [-1, 1];
            } else {
              range = Math.abs(domain[0] - domain[1]) || domain[0];
              amount = range * padPercent;
              amount /= 2;
              result[key] = [domain[0] - amount, domain[1] + amount];
            }
          }
        }
        return result;
      },

      /*
      Assigns a numeric 'index' to each series, which is used to uniquely
      identify it. Stores this index in chart.metadata
       */
      indexify: function(data, metadata) {
        data.forEach(function(d) {
          if (metadata[d.key] == null) {
            return metadata[d.key] = {};
          }
        });
        data.filter(function(d) {
          var ref;
          return (d.type == null) || ((ref = d.type) !== 'region' && ref !== 'marker');
        }).forEach(function(d, i) {
          return metadata[d.key].index = i;
        });
        return data;
      },

      /*
      TODO: Add data normalization routine
      It should fill in missing gaps and sort the data in ascending order.
       */
      normalize: function(data) {},

      /*
      Utility class that uses d3.bisect to find the index in a given array,
      where a search value can be inserted.
      This is different from normal bisectLeft; this function finds the nearest
      index to insert the search value.
      For instance, lets say your array is [1,2,3,5,10,30], and you search for 28.
      Normal d3.bisectLeft will return 4, because 28 is inserted after the number
      10.
      
      But smartBisect will return 5
      because 28 is closer to 30 than 10.
      Has the following known issues:
         * Will not work if the data points move backwards (ie, 10,9,8,7, etc) or
         if the data points are in random order.
         * Won't work if there are duplicate x coordinate values.
       */
      smartBisect: function(values, search, getX) {
        var bisect, index, nextVal, prevIndex, prevVal;
        if (getX == null) {
          getX = function(d) {
            return d[0];
          };
        }
        if (!(values instanceof Array)) {
          return null;
        }
        if (values.length === 0) {
          return null;
        }
        if (values.length === 1) {
          return 0;
        }
        if (search >= values[values.length - 1]) {
          return values.length - 1;
        }
        if (search <= values[0]) {
          return 0;
        }
        bisect = function(vals, sch) {
          var hi, lo, mid;
          lo = 0;
          hi = vals.length;
          while (lo < hi) {
            mid = (lo + hi) >>> 1;
            if (getX(vals[mid], mid) < sch) {
              lo = mid + 1;
            } else {
              hi = mid;
            }
          }
          return lo;
        };
        index = bisect(values, search);
        index = d3.min([index, values.length - 1]);
        if (index > 0) {
          prevIndex = index - 1;
          prevVal = getX(values[prevIndex], prevIndex);
          nextVal = getX(values[index], index);
          if (Math.abs(search - prevVal) < Math.abs(search - nextVal)) {
            index = prevIndex;
          }
        }
        return index;
      },
      defaultColor: function(i) {
        return colors20[i % colors20.length];
      },
      debounce: function(fn, delay) {
        var promise;
        promise = null;
        return function() {
          var args;
          args = arguments;
          window.clearTimeout(promise);
          return promise = window.setTimeout((function(_this) {
            return function() {
              promise = null;
              return fn.apply(_this, args);
            };
          })(this), delay);
        };
      },
      textWidthApprox: function(xValues, format) {
        var sample;
        if (xValues == null) {
          return 100;
        }
        sample = '' + format(xValues[0] || '');
        return sample.length * 10 + 40;
      },

      /*
      Returns an array that is a good approximation for what ticks should
      be shown on x-axis.
      
      xValues - array of all available x-axis values
      numTicks - max number of ticks that can fit on the axis
      widthThreshold - minimum distance between ticks allowed.
       */
      tickValues: function(xValues, numTicks, widthThreshold) {
        var L, counter, dist, increment, result;
        if (widthThreshold == null) {
          widthThreshold = 1;
        }
        if (numTicks === 0) {
          return [];
        }
        L = xValues.length;
        if (L <= 2) {
          return xValues;
        }
        result = [xValues[0]];
        counter = 0;
        increment = Math.ceil(L / numTicks);
        while (counter < L - 1) {
          counter += increment;
          if (counter >= L - 1) {
            break;
          }
          result.push(xValues[counter]);
        }
        dist = xValues[L - 1] - result[result.length - 1];
        if (dist < widthThreshold) {
          result.pop();
        }
        result.push(xValues[L - 1]);
        return result;
      }
    };
  })();

}).call(this);


/*
Returns an API object that performs calculations and operations on a chart
data object.

Some operations can mutate the original chart data.
 */

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
            label: d.label || d.key,
            hidden: chart.metadata(d).hidden === true,
            color: chart.seriesColor(d)
          };
        });
      },
      updateValues: function(key, values) {
        var d, j, len;
        for (j = 0, len = data.length; j < len; j++) {
          d = data[j];
          if (d.key === key) {
            d.values = values;
            break;
          }
        }
        return this;
      },
      hide: function(keys, flag) {
        var d, j, len, metadata, ref;
        if (flag == null) {
          flag = true;
        }
        metadata = chart.metadata();
        if (!(keys instanceof Array)) {
          keys = [keys];
        }
        for (j = 0, len = data.length; j < len; j++) {
          d = data[j];
          if (ref = d.key, indexOf.call(keys, ref) >= 0) {
            metadata[d.key].hidden = flag;
          }
        }
        return this;
      },
      show: function(keys) {
        return this.hide(keys, false);
      },
      toggle: function(keys) {
        var d, j, len, metadata, ref;
        metadata = chart.metadata();
        if (!(keys instanceof Array)) {
          keys = [keys];
        }
        for (j = 0, len = data.length; j < len; j++) {
          d = data[j];
          if (ref = d.key, indexOf.call(keys, ref) >= 0) {
            metadata[d.key].hidden = !metadata[d.key].hidden;
          }
        }
        return this;
      },
      showOnly: function(key) {
        var d, j, len, metadata;
        metadata = chart.metadata();
        for (j = 0, len = data.length; j < len; j++) {
          d = data[j];
          metadata[d.key].hidden = !(d.key === key);
        }
        return this;
      },
      showAll: function() {
        var d, j, len, metadata;
        metadata = chart.metadata();
        for (j = 0, len = data.length; j < len; j++) {
          d = data[j];
          metadata[d.key].hidden = false;
        }
        return this;
      },
      visible: function() {
        return data.filter(function(d) {
          return !chart.metadata(d).hidden;
        });
      },
      _getSliceable: function() {
        return data.filter(function(d) {
          return (d.values != null) && d.type !== 'region';
        });
      },
      _xValues: function(getX) {
        var dataObjs;
        dataObjs = this._getSliceable();
        if (dataObjs[0] == null) {
          return [];
        }
        return dataObjs[0].values.map(getX);
      },
      xValues: function() {
        return this._xValues(chart.getXInternal());
      },
      xValuesRaw: function() {
        return this._xValues(chart.getX());
      },
      xValueAt: function(i) {
        var dataObjs, point;
        dataObjs = this._getSliceable();
        if (dataObjs[0] == null) {
          return null;
        }
        point = dataObjs[0].values[i];
        if (point != null) {
          return chart.getX()(point);
        } else {
          return null;
        }
      },

      /*
      For a set of data series, grabs a slice of the data at a certain index.
      Useful for making the tooltip.
       */
      sliced: function(idx) {
        return this._getSliceable().filter(function(d) {
          return !chart.metadata(d).hidden;
        }).map(function(d) {
          var point;
          point = d.values[idx];
          return {
            x: chart.getX()(point, idx),
            y: chart.getY()(point, idx),
            key: d.key,
            label: d.label,
            color: chart.seriesColor(d)
          };
        });
      },
      _barItems: function() {
        return this.visible().filter(function(d) {
          return d.type === 'bar';
        });
      },

      /*
      Count how many visible bar series items there are.
      Used for doing bar chart math.
       */
      barCount: function() {
        return this._barItems().length;
      },

      /*
      Returns the index of the bar item given a key.
      Only takes into account visible bar items.
      Returns null if the key specified is not a bar item
       */
      barIndex: function(key) {
        var i, item, j, len, ref;
        ref = this._barItems();
        for (i = j = 0, len = ref.length; j < len; i = ++j) {
          item = ref[i];
          if (item.key === key) {
            return i;
          }
        }
        return null;
      },
      quadtree: function() {
        var allPoints;
        allPoints = this._getSliceable().filter(function(d) {
          return !chart.metadata(d).hidden;
        }).map(function(s, i) {
          return s.values.map(function(d, i) {
            return {
              x: chart.getXInternal()(d, i),
              y: chart.getY()(d, i),
              xValue: chart.getX()(d, i),
              series: s,
              data: d
            };
          });
        });
        allPoints = d3.merge(allPoints);
        return d3.geom.quadtree().x(function(d) {
          return d.x;
        }).y(function(d) {
          return d.y;
        })(allPoints);
      },

      /*
      Alias to chart.render(). Allows you to do things like:
      chart.data().show('mySeries').render()
       */
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
      var data, items, itemsEnter, showAll;
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
      itemsEnter = items.enter().append('div').classed('item', true);
      items.on('click', (function(_this) {
        return function(d) {
          return _this.chartInstance.data().toggle(d.key).render();
        };
      })(this));
      items.classed('disabled', function(d) {
        return d.hidden;
      });
      itemsEnter.append('span').classed('color-square', true).style('background-color', function(d) {
        return d.color;
      });
      itemsEnter.append('span').classed('description', true).text(function(d) {
        return d.label;
      });
      return itemsEnter.append('span').classed('show-only button', true).text('only').on('click', (function(_this) {
        return function(d) {
          d3.event.stopPropagation();
          return _this.chartInstance.data().showOnly(d.key).render();
        };
      })(this));
    };

    return Legend;

  })();

}).call(this);


/*
Library of tooltip rendering utilities
 */

(function() {
  this.ForestD3.TooltipContent = {
    multiple: function(chart, xIndex) {
      var rows, slice, xValue;
      xValue = chart.data().xValueAt(xIndex);
      xValue = chart.xTickFormat()(xValue);
      slice = chart.data().sliced(xIndex);
      rows = slice.map(function(d) {
        var bgColor;
        bgColor = "background-color: " + d.color + ";";
        return "<tr>\n    <td><div class='series-color' style='" + bgColor + "'></div></td>\n    <td class='series-label'>" + (d.label || d.key) + "</td>\n    <td class='series-value'>" + (chart.yTickFormat()(d.y)) + "</td>\n</tr>";
      });
      rows = rows.join('');
      return "<div class='header'>" + xValue + "</div>\n<table>\n    " + rows + "\n</table>";
    },
    single: function(chart, point) {
      var bgColor, color, label, xValue;
      xValue = chart.xTickFormat()(point.xValue);
      color = chart.seriesColor(point.series);
      bgColor = "background-color: " + color + ";";
      label = point.series.label || point.series.key;
      return "<div class='header'>" + xValue + "</div>\n<table>\n    <tr>\n        <td><div class='series-color' style='" + bgColor + "'></div></td>\n        <td class='series-label'>" + label + "</td>\n        <td class='series-value'>\n            " + (chart.yTickFormat()(point.y)) + "\n        </td>\n    </tr>\n</table>";
    }
  };

}).call(this);

(function() {
  var Tooltip;

  this.ForestD3.Tooltip = Tooltip = (function() {
    function Tooltip(chart) {
      this.chart = chart;
      this.container = null;
    }


    /*
    content: string or DOM object or d3 object representing tooltip content.
    clientMouse: Array of [mouse screen x, mouse screen y] positions
     */

    Tooltip.prototype.render = function(content, clientMouse) {
      var containerCenter, dimensions, edgeThreshold, xPos, yPos;
      if (!this.chart.showTooltip()) {
        return;
      }
      if (this.container == null) {
        this.container = document.createElement('div');
        document.body.appendChild(this.container);
      }
      if ((typeof content === 'string') || (typeof content === 'number')) {
        d3.select(this.container).classed('forest-d3 tooltip-box', true).html(content);
      }

      /*
      xPos and yPos are the relative coordinates of the mouse in the
      browser window.
      
      Adding page offset to it takes into account any scrolling.
      
      Because the tooltip DIV is placed on document.body, this should give
      us the absolute correct position.
       */
      xPos = clientMouse[0], yPos = clientMouse[1];
      xPos += window.pageXOffset;
      yPos += window.pageYOffset;

      /*
      Adjust tooltip so that it is centered on the mouse.
      Accomplish this by calculating container height and dividing it by 2.
       */
      dimensions = this.container.getBoundingClientRect();
      containerCenter = dimensions.height / 2;
      yPos -= containerCenter;

      /*
      Check to see if the tooltip will render past the right side of the
      browser window. If so, then move it to the left of the mouse.
       */
      edgeThreshold = 40;
      if ((xPos + dimensions.width + edgeThreshold) > window.innerWidth) {
        xPos -= dimensions.width + edgeThreshold;
      }
      return d3.select(this.container).style('left', xPos + "px").style('top', yPos + "px").transition().style('opacity', 0.9);
    };

    Tooltip.prototype.hide = function() {
      if (!this.chart.showTooltip()) {
        return;
      }
      return d3.select(this.container).transition().delay(250).style('opacity', 0).each('end', function() {
        return d3.select(this).style('left', '0px').style('top', '0px');
      });
    };

    Tooltip.prototype.destroy = function() {
      if (this.container != null) {
        return document.body.removeChild(this.container);
      }
    };

    return Tooltip;

  })();

}).call(this);


/*
Handles the guideline that moves along the x-axis
 */

(function() {
  var Guideline;

  this.ForestD3.Guideline = Guideline = (function() {
    function Guideline(chart) {
      this.chart = chart;
    }

    Guideline.prototype.create = function(canvas) {
      if (!this.chart.showGuideline()) {
        return;
      }
      this.line = canvas.selectAll('line.guideline').data([this.chart.canvasHeight]);
      this.line.enter().append('line').classed('guideline', true).style('opacity', 0);
      this.line.attr('y1', 0).attr('y2', function(d) {
        return d;
      });
      this.markerContainer = canvas.selectAll('g.guideline-markers').data([0]);
      return this.markerContainer.enter().append('g').classed('guideline-markers', true);
    };

    Guideline.prototype.render = function(xPosition, xIndex) {
      var markers, slice;
      if (!this.chart.showGuideline()) {
        return;
      }
      if (this.line == null) {
        return;
      }
      this.line.attr('x1', xPosition).attr('x2', xPosition).transition().style('opacity', 0.5);
      slice = this.chart.data().sliced(xIndex);
      this.markerContainer.transition().style('opacity', 1);
      markers = this.markerContainer.selectAll('circle.marker').data(slice);
      markers.enter().append('circle').classed('marker', true).attr('r', 3);
      markers.exit().remove();
      return markers.attr('cx', xPosition).attr('cy', (function(_this) {
        return function(d) {
          return _this.chart.yScale(d.y);
        };
      })(this)).style('fill', function(d) {
        return d.color;
      });
    };

    Guideline.prototype.hide = function() {
      if (!this.chart.showGuideline()) {
        return;
      }
      if (this.line == null) {
        return;
      }
      this.line.transition().delay(250).style('opacity', 0);
      return this.markerContainer.transition().delay(250).style('opacity', 0);
    };

    return Guideline;

  })();

}).call(this);


/*
Handles the guideline that moves along the x-axis
 */

(function() {
  var Crosshairs;

  this.ForestD3.Crosshairs = Crosshairs = (function() {
    function Crosshairs(chart) {
      this.chart = chart;
    }

    Crosshairs.prototype.create = function(canvas) {
      if (!this.chart.showGuideline()) {
        return;
      }
      this.xLine = canvas.selectAll('line.crosshair-x').data([this.chart.canvasHeight]);
      this.yLine = canvas.selectAll('line.crosshair-y').data([this.chart.canvasWidth]);
      this.xLine.enter().append('line').classed('crosshair-x', true).style('stroke-opacity', 0);
      this.xLine.attr('y1', 0).attr('y2', function(d) {
        return d;
      });
      this.yLine.enter().append('line').classed('crosshair-y', true).style('stroke-opacity', 0);
      return this.yLine.attr('x1', 0).attr('x2', function(d) {
        return d;
      });
    };

    Crosshairs.prototype.render = function(x, y) {
      if (!this.chart.showGuideline()) {
        return;
      }
      if (this.xLine == null) {
        return;
      }
      this.xLine.transition().duration(50).attr('x1', x).attr('x2', x).style('stroke-opacity', 0.5);
      return this.yLine.transition().duration(50).attr('y1', y).attr('y2', y).style('stroke-opacity', 0.5);
    };

    Crosshairs.prototype.hide = function() {
      if (!this.chart.showGuideline()) {
        return;
      }
      if (this.xLine == null) {
        return;
      }
      this.xLine.transition().delay(250).style('stroke-opacity', 0);
      return this.yLine.transition().delay(250).style('stroke-opacity', 0);
    };

    return Crosshairs;

  })();

}).call(this);

(function() {
  var Chart, chartProperties,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  chartProperties = [
    [
      'getX', function(d, i) {
        return d[0];
      }
    ], [
      'getY', function(d, i) {
        return d[1];
      }
    ], ['forceDomain', null], ['ordinal', false], ['autoResize', true], ['color', ForestD3.Utils.defaultColor], ['duration', 250], ['pointSize', 4], ['xPadding', 0.1], ['yPadding', 0.1], ['xLabel', ''], ['yLabel', ''], ['chartLabel', ''], ['xScaleType', d3.scale.linear], ['yScaleType', d3.scale.linear], [
      'xTickFormat', function(d) {
        return d;
      }
    ], ['yTickFormat', d3.format(',.2f')], ['xTicks', null], ['yTicks', null], ['showXAxis', true], ['showYAxis', true], ['showTooltip', true], ['showGuideline', true], ['tooltipType', 'bisect']
  ];

  this.ForestD3.Chart = Chart = (function(superClass) {
    extend(Chart, superClass);

    function Chart(domContainer) {
      Chart.__super__.constructor.call(this, domContainer);
      this._setProperties(chartProperties);
      this.tooltip = new ForestD3.Tooltip(this);
      this.guideline = new ForestD3.Guideline(this);
      this.crosshairs = new ForestD3.Crosshairs(this);
      this.xAxis = d3.svg.axis();
      this.yAxis = d3.svg.axis();
      this.seriesColor = (function(_this) {
        return function(d) {
          return d.color || _this.color()(_this.metadata(d).index);
        };
      })(this);
      this.getXInternal = (function(_this) {
        return function() {
          if (_this.ordinal()) {
            return function(d, i) {
              return i;
            };
          } else {
            return _this.getX();
          }
        };
      })(this);
    }

    Chart.prototype.destroy = function() {
      Chart.__super__.destroy.call(this);
      return this.tooltip.destroy();
    };


    /*
    Set chart data.
     */

    Chart.prototype.data = function(d) {
      if (d == null) {
        return ForestD3.DataAPI.call(this, this.chartData);
      } else {
        d = ForestD3.Utils.indexify(d, this._metadata);
        this.chartData = d;
        if (this.tooltipType() === 'spatial') {
          this.quadtree = this.data().quadtree();
        }
        return this;
      }
    };


    /*
    Main rendering logic.  Here we should update the chart frame, axes
    and series points.
     */

    Chart.prototype.render = function() {
      var chart, chartItems;
      if (this.svg == null) {
        return this;
      }
      if (this.chartData == null) {
        return this;
      }
      this.updateDimensions();
      this.updateChartScale();
      this.updateChartFrame();
      chartItems = this.canvas.selectAll('g.chart-item').data(this.data().visible(), function(d) {
        return d.key;
      });
      chartItems.enter().append('g').attr('class', function(d, i) {
        return "chart-item item-" + (d.key || i);
      });
      chartItems.exit().transition().duration(this.duration()).style('opacity', 0).remove();
      chart = this;

      /*
      Main render loop. Loops through the data array, and depending on the
      'type' attribute, renders a different kind of chart element.
       */
      chartItems.each(function(d, i) {
        var chartItem, renderFn;
        renderFn = function() {
          return 0;
        };
        chartItem = d3.select(this);
        if ((d.type === 'scatter') || ((d.type == null) && (d.values != null))) {
          renderFn = ForestD3.ChartItem.scatter;
        } else if (d.type === 'line') {
          renderFn = ForestD3.ChartItem.line;
        } else if (d.type === 'bar') {
          renderFn = ForestD3.ChartItem.bar;
        } else if (d.type === 'ohlc') {
          renderFn = ForestD3.ChartItem.ohlc;
        } else if ((d.type === 'marker') || ((d.type == null) && (d.value != null))) {
          renderFn = ForestD3.ChartItem.markerLine;
        } else if (d.type === 'region') {
          renderFn = ForestD3.ChartItem.region;
        }
        return renderFn.call(chart, chartItem, d);
      });

      /*
      This line keeps chart-items in order on the canvas. Items that appear
      lower in the list thus overlap items that are near the beginning of the
      list.
       */
      chartItems.order();
      this.renderPlugins();
      this.trigger('rendered', this.metadata());
      return this;
    };


    /*
    Get or set the chart's margins.
    Takes an object or a list of arguments (top, right, bottom, left)
    
    Example:
        margin({left: 90, top: 30})
        margin(30,null,null,90)
     */

    Chart.prototype.margin = function(m) {
      var arg, args, defaults, i, j, k, key, keyOrder, len, len1;
      defaults = {
        left: 80,
        bottom: 50,
        right: 20,
        top: 20
      };
      if (!this._chartMargins) {
        this._chartMargins = defaults;
      }
      if (arguments.length === 0) {
        return this._chartMargins;
      } else {
        keyOrder = ['top', 'right', 'bottom', 'left'];
        if ((m != null) && (typeof m) === 'object') {
          for (j = 0, len = keyOrder.length; j < len; j++) {
            key = keyOrder[j];
            if (m[key] != null) {
              this._chartMargins[key] = m[key];
            }
          }
        } else {
          args = Array.prototype.slice.apply(arguments);
          for (i = k = 0, len1 = args.length; k < len1; i = ++k) {
            arg = args[i];
            if ((typeof arg) === 'number' && i < keyOrder.length) {
              this._chartMargins[keyOrder[i]] = arg;
            }
          }
        }
        return this;
      }
    };


    /*
    Get the chart's dimensions, based on the parent container <div>.
    Calculate chart margins and canvas dimensions.
     */

    Chart.prototype.updateDimensions = function() {
      var bounds, container, margin;
      container = this.container();
      if (container != null) {
        bounds = container.getBoundingClientRect();
        this.height = bounds.height;
        this.width = bounds.width;
        margin = this.margin();
        this.canvasHeight = this.height - margin.bottom - margin.top;
        return this.canvasWidth = this.width - margin.left - margin.right;
      }
    };


    /*
    Draws the chart frame. Things like backdrop and canvas.
     */

    Chart.prototype.updateChartFrame = function() {
      var axesLabels, backdrop, canvasEnter, chart, chartLabel, margin, tickValues, widthThreshold, xAxisGroup, xAxisLabel, xTickWidth, xTicks, xValues, xValuesRaw, yAxisGroup, yAxisLabel;
      backdrop = this.svg.selectAll('rect.backdrop').data([0]);
      backdrop.enter().append('rect').classed('backdrop', true);
      backdrop.attr('width', this.width).attr('height', this.height);
      margin = this.margin();
      if (this.showXAxis()) {
        tickValues = null;
        xValuesRaw = this.data().xValuesRaw();
        if (this.ordinal()) {

          /*
          For ordinal scales, attempts to fit as many x-ticks as possible.
          Will always show the first and last ticks, and fill in the
          space in between.
           */
          xTickWidth = ForestD3.Utils.textWidthApprox(xValuesRaw, this.xTickFormat());
          xValues = this.data().xValues();
          xTicks = this.canvasWidth / xTickWidth;
          widthThreshold = Math.ceil(this.xScale.invert(xTickWidth));
          tickValues = ForestD3.Utils.tickValues(xValues, xTicks, widthThreshold);
        }
        this.xAxis.scale(this.xScale).tickSize(10, 10).tickValues(tickValues).tickPadding(5).tickFormat((function(_this) {
          return function(d) {
            var tick;
            tick = _this.ordinal() ? xValuesRaw[d] : d;
            return _this.xTickFormat()(tick, d);
          };
        })(this));
        xAxisGroup = this.svg.selectAll('g.x-axis').data([0]);
        xAxisGroup.enter().append('g').attr('class', 'x-axis axis');
        xAxisGroup.attr('transform', "translate(" + margin.left + ", " + (this.canvasHeight + margin.top) + ")");
        xAxisGroup.transition().duration(this.duration()).call(this.xAxis);
      }
      if (this.showYAxis()) {
        this.yAxis.scale(this.yScale).orient('left').ticks(this.yTicks()).tickSize(-this.canvasWidth, 10).tickPadding(10).tickFormat(this.yTickFormat());
        yAxisGroup = this.svg.selectAll('g.y-axis').data([0]);
        yAxisGroup.enter().append('g').attr('class', 'y-axis axis');
        yAxisGroup.attr('transform', "translate(" + margin.left + ", " + margin.top + ")");
        yAxisGroup.transition().duration(this.duration()).call(this.yAxis);
      }
      this.canvas = this.svg.selectAll('g.canvas').data([0]);
      canvasEnter = this.canvas.enter().append('g').classed('canvas', true);
      this.canvas.attr('transform', "translate(" + margin.left + ", " + margin.top + ")");
      canvasEnter.append('rect').classed('canvas-backdrop', true);
      chart = this;
      this.canvas.select('rect.canvas-backdrop').attr('width', this.canvasWidth).attr('height', this.canvasHeight).on('mousemove', function() {
        return chart.updateTooltip(d3.mouse(this), [d3.event.clientX, d3.event.clientY]);
      }).on('mouseout', function() {
        return chart.updateTooltip(null);
      });
      this.guideline.create(this.canvas);
      this.crosshairs.create(this.canvas);
      axesLabels = this.canvas.selectAll('g.axes-labels').data([0]);
      axesLabels.enter().append('g').classed('axes-labels', true);
      xAxisLabel = axesLabels.selectAll('text.x-axis').data([this.xLabel()]);
      xAxisLabel.enter().append('text').classed('x-axis', true).attr('text-anchor', 'end').attr('x', 0).attr('y', this.canvasHeight);
      xAxisLabel.text(function(d) {
        return d;
      }).transition().duration(this.duration()).attr('x', this.canvasWidth);
      yAxisLabel = axesLabels.selectAll('text.y-axis').data([this.yLabel()]);
      yAxisLabel.enter().append('text').classed('y-axis', true).attr('text-anchor', 'end').attr('transform', 'translate(10,0) rotate(-90 0 0)');
      yAxisLabel.text(function(d) {
        return d;
      });
      chartLabel = axesLabels.selectAll('text.chart-label').data([this.chartLabel()]);
      chartLabel.enter().append('text').classed('chart-label', true).attr('text-anchor', 'end');
      return chartLabel.text(function(d) {
        return d;
      }).attr('y', 0).attr('x', this.canvasWidth);
    };

    Chart.prototype.updateChartScale = function() {
      var extent;
      extent = ForestD3.Utils.extent(this.data().visible(), this.getXInternal(), this.getY(), this.forceDomain());
      extent = ForestD3.Utils.extentPadding(extent, {
        x: this.xPadding(),
        y: this.yPadding()
      });
      this.yScale = this.yScaleType()().domain(extent.y).range([this.canvasHeight, 0]);
      return this.xScale = this.xScaleType()().domain(extent.x).range([0, this.canvasWidth]);
    };


    /*
    Updates where the guideline and tooltip is.
    
    mouse: [mouse x , mouse y] - location of mouse in canvas
    clientMouse should be an array: [x,y] - location of mouse in browser
     */

    Chart.prototype.updateTooltip = function(mouse, clientMouse) {
      var content, dist, idx, isHidden, point, threshold, x, xActual, xDiff, xPos, xValues, y, yActual, yDiff, yPos;
      if (!this.showTooltip()) {
        return;
      }
      if (mouse == null) {
        this.guideline.hide();
        this.crosshairs.hide();
        return this.tooltip.hide();
      } else {
        xPos = mouse[0], yPos = mouse[1];
        if (this.tooltipType() === 'bisect') {

          /*
          Bisect tooltip algorithm works as follows:
          
          - Given the current X position, look up the index of the
              closest point, which is basically a binary search.
          - Calculate the x pixel location of the found point.
          - Render the guideline at that point.
          - Do a 'slice' of the data at the found index and render
              tooltip with all values at the current index.
           */
          xValues = this.data().xValues();
          idx = ForestD3.Utils.smartBisect(xValues, this.xScale.invert(xPos), function(d) {
            return d;
          });
          xPos = this.xScale(xValues[idx]);
          this.guideline.render(xPos, idx);
          content = ForestD3.TooltipContent.multiple(this, idx);
          return this.tooltip.render(content, clientMouse);
        } else if (this.tooltipType() === 'spatial') {

          /*
          Spatial tooltip algorithm works as follows:
          
          - Convert current mouse position into the domain coordinates
          - Using those coordinates, look up the closest point in the
              quadtree data structure.
          - Calculate distance between found point and mouse location.
          - If the distance is under a certain threshold, render the
              tooltip and crosshairs. Otherwise hide them.
          
          - the threshold is calculated by dividing the canvas into
              many small squares and using the diagnol length of each
              square. It was found through trial and error.
           */
          x = this.xScale.invert(xPos);
          y = this.yScale.invert(yPos);
          point = this.quadtree.find([x, y]);
          xActual = this.xScale(point.x);
          yActual = this.yScale(point.y);
          xDiff = xActual - xPos;
          yDiff = yActual - yPos;
          dist = Math.sqrt(xDiff * xDiff + yDiff * yDiff);
          threshold = Math.sqrt((2 * this.canvasWidth * this.canvasHeight) / 1965);

          /*
          There is an additional check to make sure tooltips are not
          rendered for hidden chart series'.
           */
          isHidden = this.metadata(point.series).hidden;
          if (dist < threshold && !isHidden) {
            content = ForestD3.TooltipContent.single(this, point);
            this.crosshairs.render(xActual, yActual);
            return this.tooltip.render(content, clientMouse);
          } else {
            this.crosshairs.hide();
            return this.tooltip.hide();
          }
        }
      }
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

  })(ForestD3.BaseChart);

}).call(this);

(function() {
  var BarChart, chartProperties,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  chartProperties = [
    ['autoResize', true], [
      'getX', function(d) {
        return d[0];
      }
    ], [
      'getY', function(d) {
        return d[1];
      }
    ], ['height', null], ['barHeight', 40], ['barPadding', 10], [
      'sortBy', function(d) {
        return d[0];
      }
    ], ['sortDirection', null]
  ];

  this.ForestD3.BarChart = BarChart = (function(superClass) {
    extend(BarChart, superClass);

    function BarChart(domContainer) {
      BarChart.__super__.constructor.call(this, domContainer);
      d3.select(this.container()).classed('auto-height bar-chart', true);
      this._setProperties(chartProperties);
      this.getXInternal = function(d, i) {
        return i;
      };
    }


    /*
    Set chart data.
     */

    BarChart.prototype.data = function(d) {
      if (d == null) {
        return ForestD3.DataAPI.call(this, this.chartData);
      } else {
        this.chartData = d;
        return this;
      }
    };

    BarChart.prototype._barData = function() {
      return this.data().get()[0].values;
    };

    BarChart.prototype._barDataSorted = function() {
      var d, getVal, j, len, ref, result;
      if (!this.sortDirection()) {
        return this._barData();
      }
      result = [];
      ref = this._barData();
      for (j = 0, len = ref.length; j < len; j++) {
        d = ref[j];
        result.push(d);
      }
      getVal = this.sortBy();
      if (this.sortDirection() === 'asc') {
        result.sort(function(a, b) {
          return d3.ascending(getVal(a), getVal(b));
        });
      } else {
        result.sort(function(a, b) {
          return d3.descending(getVal(a), getVal(b));
        });
      }
      return result;
    };


    /*
    A function that finds the longest label and computes an approximate
    pixel width for it. Used to determine how much left margin there should
    be.
    The technique used is: create a temporary <text> element and put
    the longest label in it. Then use getBoundingClientRect to find the width.
    Quickly remove it after.
     */

    BarChart.prototype.calcMaxTextWidth = function() {
      var j, label, labels, len, maxL, maxLabel, size, text;
      labels = this._barData().map((function(_this) {
        return function(d, i) {
          return _this.getX()(d, i);
        };
      })(this));
      maxL = 0;
      maxLabel = '';
      for (j = 0, len = labels.length; j < len; j++) {
        label = labels[j];
        if (label.length > maxL) {
          maxL = label.length;
          maxLabel = label;
        }
      }
      text = this.svg.append('text').text(maxLabel);
      size = text.node().getBoundingClientRect().width;
      text.remove();
      return size + 20;
    };

    BarChart.prototype.render = function() {
      var barY, bars, chart, color, labels, valueLabels, zeroLine, zeroPosition;
      if (this.svg == null) {
        return;
      }
      if (this.chartData == null) {
        return;
      }
      this.updateDimensions();
      this.updateChartScale();
      this.updateChartFrame();
      barY = (function(_this) {
        return function(i) {
          return _this.barHeight() * i + _this.barPadding() * i;
        };
      })(this);
      chart = this;
      color = this.data().get()[0].color;
      labels = this.labelGroup.selectAll('text').data(this._barDataSorted(), function(d) {
        return d;
      });
      labels.enter().append('text').attr('text-anchor', 'end').attr('x', 0).attr('y', 0).style('fill-opacity', 0);
      labels.exit().remove();
      labels.each(function(d, i) {
        var isNegative;
        isNegative = chart.getY()(d, i) < 0;
        return d3.select(this).classed('positive', !isNegative).classed('negative', isNegative).text(chart.getX()(d, i)).transition().duration(700).delay(i * 20).attr('y', barY(i)).style('fill-opacity', 1);
      });
      zeroPosition = chart.yScale(0);
      bars = this.barGroup.selectAll('rect').data(this._barDataSorted(), function(d) {
        return d;
      });
      bars.enter().append('rect').attr('x', zeroPosition).attr('y', 0).style('fill-opacity', 0).style('stroke-opacity', 0);
      bars.exit().remove();
      bars.each(function(d, i) {
        var isNegative, translate, width;
        width = (function() {
          var yPos;
          yPos = chart.yScale(chart.getY()(d, i));
          return Math.abs(yPos - zeroPosition);
        })();
        isNegative = chart.getY()(d, i) < 0;
        translate = isNegative ? "translate(" + (-width) + ", 0)" : '';
        return d3.select(this).attr('height', chart.barHeight()).attr('transform', translate).classed('positive', !isNegative).classed('negative', isNegative).transition().attr('width', width).style('fill', color).duration(700).delay(i * 50).attr('x', zeroPosition).attr('y', barY(i)).style('fill-opacity', 1).style('stroke-opacity', 0.7);
      });
      valueLabels = this.valueGroup.selectAll('text').data(this._barDataSorted(), function(d) {
        return d;
      });
      valueLabels.enter().append('text').attr('x', 0);
      valueLabels.exit().remove();
      valueLabels.each(function(d, i) {
        var isNegative, xPos, yVal;
        yVal = chart.getY()(d, i);
        isNegative = yVal < 0;
        xPos = isNegative ? zeroPosition : chart.yScale(yVal);
        return d3.select(this).classed('positive', !isNegative).classed('negative', isNegative).transition().duration(700).attr('y', barY(i)).delay(i * 20).text(yVal).attr('x', xPos);
      });
      zeroLine = this.barGroup.selectAll('line.zero-line').data([0]);
      zeroLine.enter().append('line').classed('zero-line', true);
      zeroLine.transition().attr('x1', zeroPosition).attr('x2', zeroPosition).attr('y1', 0).attr('y2', this.canvasHeight);
      return this;
    };


    /*
    Get the chart's dimensions, based on the parent container <div>.
    Calculate chart margins and canvas dimensions.
     */

    BarChart.prototype.updateDimensions = function() {
      var barCount, bounds, container;
      container = this.container();
      if (container != null) {
        bounds = container.getBoundingClientRect();
        this.margin = {
          left: this.calcMaxTextWidth(),
          right: 50
        };
        this.canvasWidth = bounds.width - this.margin.left - this.margin.right;
        if (!this.height()) {
          barCount = this._barData().length;
          this.canvasHeight = barCount * (this.barHeight() + this.barPadding());
          return this.svg.attr('height', this.canvasHeight);
        }
      }
    };

    BarChart.prototype.updateChartScale = function() {
      var extent;
      extent = ForestD3.Utils.extent(this.data().get(), this.getXInternal(), this.getY());
      extent.y = d3.extent(extent.y.concat([0]));
      return this.yScale = d3.scale.linear().domain(extent.y).range([0, this.canvasWidth]);
    };


    /*
    Draws the chart frame. Things like backdrop and canvas.
     */

    BarChart.prototype.updateChartFrame = function() {
      var barCenter, padding;
      padding = 10;
      barCenter = this.barHeight() / 2 + 5;
      this.labelGroup = this.svg.selectAll('g.bar-labels').data([0]);
      this.labelGroup.enter().append('g').classed('bar-labels', true);
      this.labelGroup.attr('transform', "translate(" + (this.margin.left - padding) + "," + barCenter + ")");
      this.barGroup = this.svg.selectAll('g.bars').data([0]);
      this.barGroup.enter().append('g').classed('bars', true);
      this.barGroup.attr('transform', "translate(" + this.margin.left + ",0)");
      this.valueGroup = this.svg.selectAll('g.bar-values').data([0]);
      this.valueGroup.enter().append('g').classed('bar-values', true);
      return this.valueGroup.attr('transform', "translate(" + (this.margin.left + padding) + "," + barCenter + ")");
    };

    return BarChart;

  })(ForestD3.BaseChart);

}).call(this);
