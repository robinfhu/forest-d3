
/*
********************************************************
Forest D3 - a charting library using d3.js

Author:  Robin Hu

********************************************************
 */

(function() {
  if (typeof d3 === "undefined" || d3 === null) {
    throw new Error("d3.js has not been included. See http://d3js.org/ for how to include it.");
  }

  this.ForestD3 = {
    version: '0.3.0-beta'
  };

  this.ForestD3.Visualizations = {};

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

    BaseChart.prototype.on = function(type, listener) {
      return this._dispatch.on(type, listener);
    };

    BaseChart.prototype.trigger = function(type) {
      return this._dispatch[type].apply(this, Array.prototype.slice.call(arguments, 1));
    };

    BaseChart.prototype._attachStateHandlers = function() {};

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
      return ForestD3.Utils.setProperties(this, this.properties, chartProperties);
    };

    return BaseChart;

  })();

}).call(this);

(function() {
  this.ForestD3.Visualizations.barStacked = function(selection, selectionData) {
    var barBase, barWidth, bars, chart, fullSpace, maxFullSpace, maxPadding, x, xCentered, y;
    chart = this;
    bars = selection.selectAll('rect.bar').data(selectionData.values);
    x = chart.getXInternal;
    y = chart.getYInternal;

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
    maxFullSpace = chart.xScale(1) / 2;
    fullSpace = d3.min([maxFullSpace, fullSpace]);
    maxPadding = 35;
    fullSpace -= d3.min([fullSpace * chart.barPaddingPercent(), maxPadding]);
    fullSpace = d3.max([1, fullSpace]);

    /*
    This is used to ensure that the bar group is centered around the x-axis
    tick mark.
     */
    xCentered = fullSpace / 2;
    bars.enter().append('rect').classed('bar', true).attr('x', function(d, i) {
      return chart.xScale(x(d, i)) - xCentered;
    }).attr('y', barBase).attr('height', 0);
    bars.exit().remove();
    barWidth = fullSpace;
    return bars.transition().duration(selectionData.duration || chart.duration()).delay(function(d, i) {
      return i * 20;
    }).attr('x', function(d, i) {

      /*
      Calculates the x position of each bar. Shifts the bar along x-axis
      depending on which series index the bar belongs to.
       */
      return chart.xScale(x(d, i)) - xCentered;
    }).attr('y', function(d, i) {

      /*
      For negative stacked bars, place the top of the <rect> at y0.
      
      For positive bars, place the top of the <rect> at y0 + y
       */
      if (d.y0 <= 0 && d.y < 0) {
        return chart.yScale(d.y0);
      } else {
        return chart.yScale(d.y0 + d.y);
      }
    }).attr('height', function(d, i) {
      return Math.abs(chart.yScale(d.y) - barBase);
    }).attr('width', barWidth).style('fill', selectionData.color).attr('class', function(d, i) {
      var additionalClass;
      additionalClass = (typeof selectionData.classed) === 'function' ? selectionData.classed(d.data, i, selectionData) : '';
      return "bar " + additionalClass;
    });
  };

}).call(this);

(function() {
  this.ForestD3.Visualizations.bar = function(selection, selectionData) {
    var barBase, barCount, barIndex, barWidth, bars, chart, fullSpace, maxFullSpace, maxPadding, x, xCentered, y;
    chart = this;
    bars = selection.selectAll('rect.bar').data(selectionData.values);
    x = chart.getXInternal;
    y = chart.getYInternal;

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
    maxPadding = 35;
    fullSpace -= d3.min([fullSpace * chart.barPaddingPercent(), maxPadding]);
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
    }).attr('width', barWidth).style('fill', selectionData.color).attr('class', function(d, i) {
      var additionalClass;
      additionalClass = (typeof selectionData.classed) === 'function' ? selectionData.classed(d.data, i, selectionData) : '';
      return "bar " + additionalClass;
    });
  };

}).call(this);


/*
Draws a simple line graph.
If you set area=true, turns it into an area graph
 */

(function() {
  this.ForestD3.Visualizations.line = function(selection, selectionData) {
    var area, areaBase, areaFn, chart, duration, interpolate, lineFn, path, x, y;
    chart = this;
    selection.style('stroke', selectionData.color);
    interpolate = selectionData.interpolate || 'linear';
    x = chart.getXInternal;
    y = chart.getYInternal;
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
      return area.transition().duration(duration).style('fill', selectionData.color).attr('d', areaFn.y1(function(d, i) {
        return chart.yScale(y(d, i));
      }));
    }
  };

}).call(this);


/*
Draws a horizontal or vertical line at the specified x or y location.
 */

(function() {
  this.ForestD3.Visualizations.markerLine = function(selection, selectionData) {
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
  this.ForestD3.Visualizations.ohlc = function(selection, selectionData) {
    var chart, close, closeMarks, duration, hi, lo, open, openMarks, rangeLines, x;
    chart = this;
    selection.classed('ohlc', true);
    rangeLines = selection.selectAll('line.ohlc-range').data(selectionData.values);
    x = chart.getXInternal;
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
      return chart.yScale(hi(d.data, i));
    }).attr('y2', function(d, i) {
      return chart.yScale(lo(d.data, i));
    });
    openMarks = selection.selectAll('line.ohlc-open').data(selectionData.values);
    openMarks.enter().append('line').classed('ohlc-open', true).attr('y1', 0).attr('y2', 0);
    openMarks.exit().remove();
    openMarks.transition().duration(duration).delay(function(d, i) {
      return i * 20;
    }).attr('y1', function(d, i) {
      return chart.yScale(open(d.data, i));
    }).attr('y2', function(d, i) {
      return chart.yScale(open(d.data, i));
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
      return chart.yScale(close(d.data, i));
    }).attr('y2', function(d, i) {
      return chart.yScale(close(d.data, i));
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
  this.ForestD3.Visualizations.region = function(selection, selectionData) {
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

Example call:
ForestD3.Visualizations.scatter.call chartInstance, d3.select(this)
 */

(function() {
  this.ForestD3.Visualizations.scatter = function(selection, selectionData) {
    var all, base, chart, points, seriesIndex, shape, symbol, x, y;
    chart = this;
    selection.style('fill', selectionData.color);
    x = chart.getXInternal;
    y = chart.getYInternal;
    all = d3.svg.symbolTypes;
    seriesIndex = selectionData.index;
    shape = selectionData.shape || all[seriesIndex % all.length];
    symbol = d3.svg.symbol().type(shape);
    points = selection.selectAll('path.point').data(function(d) {
      return d.values;
    });
    base = Math.min(chart.yScale(0), chart.canvasHeight);
    points.enter().append('path').classed('point', true).attr('transform', function(d, i) {
      return "translate(" + (chart.xScale(x(d, i))) + "," + base + ")";
    }).attr('d', symbol.size(0));
    points.exit().remove();
    points.transition().duration(selectionData.duration || chart.duration()).delay(function(d, i) {
      return i * 10;
    }).ease('quad').attr('transform', function(d, i) {
      return "translate(" + (chart.xScale(x(d, i))) + "," + (chart.yScale(y(d, i))) + ")";
    }).attr('d', symbol.size(selectionData.size || 96));
    if (chart.tooltipType() === 'hover') {
      selection.classed('interactive', true);
      return points.on('mouseover.tooltipHover', function(d, i) {
        var canvasMouse, clientMouse, content;
        clientMouse = [d3.event.clientX, d3.event.clientY];
        canvasMouse = [chart.xScale(x(d, i)), chart.yScale(y(d, i))];
        content = ForestD3.TooltipContent.single(chart, d, {
          series: selectionData
        });
        return chart.renderSpatialTooltip({
          content: content,
          clientMouse: clientMouse,
          canvasMouse: canvasMouse
        });
      }).on('mouseout.tooltipHover', function(d, i) {
        return chart.renderSpatialTooltip({
          hide: true
        });
      });
    }
  };

}).call(this);

(function() {
  this.ForestD3.Utils = (function() {
    var colors20;
    colors20 = d3.scale.category20().range();
    return {
      setProperties: function(chart, target, chartProperties) {
        var defaultVal, j, len, prop, propPair, results;
        results = [];
        for (j = 0, len = chartProperties.length; j < len; j++) {
          propPair = chartProperties[j];
          prop = propPair[0], defaultVal = propPair[1];
          target[prop] = defaultVal;
          results.push(chart[prop] = (function(prop) {
            return function(d) {
              if (typeof d === 'undefined') {
                return target[prop];
              } else {
                target[prop] = d;
                return chart;
              }
            };
          })(prop));
        }
        return results;
      },

      /*
      Calculates the minimum and maximum point across all series'.
      Useful for setting the domain for a d3.scale()
      
      data: chart data that has been passed through normalization function.
      It should be an array of objects, where each object contains an extent
      property. Example:
      [
          key: 'line1'
          extent:
              x: [1,3]
              y: [3,4]
      ,
          key: 'line2'
          extent:
              x: [1,3]
              y: [3,4]
      ]
      
      the 'force' argument allows you to force certain values onto the final
      extent. Example:
          {y: [0], x: [0]}
      
      Returns an object with the x,y axis extents:
      {
          x: [min, max]
          y: [min, max]
      }
       */
      extent: function(data, force) {
        var defaultExtent, roundOff, xExt, yExt;
        defaultExtent = [-1, 1];
        if (!data || data.length === 0) {
          return {
            x: defaultExtent,
            y: defaultExtent
          };
        }
        xExt = d3.extent(d3.merge(data.map(function(series) {
          var ref;
          return ((ref = series.extent) != null ? ref.x : void 0) || [];
        })));
        yExt = d3.extent(d3.merge(data.map(function(series) {
          var ref;
          return ((ref = series.extent) != null ? ref.y : void 0) || [];
        })));
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
      },
      convertObjectToArray: function(obj) {
        var array, data, key;
        if (obj instanceof Array) {
          return obj.slice();
        } else {
          array = [];
          for (key in obj) {
            data = obj[key];
            if (data.key == null) {
              data.key = key;
            }
            array.push(data);
          }
          return array;
        }
      },

      /*
      Create a clone of a chart data object.
       */
      clone: function(data) {
        var copy;
        copy = this.convertObjectToArray(data);
        copy = copy.map(function(d) {
          var key, newObj, val;
          newObj = {};
          for (key in d) {
            val = d[key];
            newObj[key] = val;
          }
          return newObj;
        });
        return copy;
      },

      /*
      Converts the input data into a normalized format.
      Also clones the data so the chart operates on copy of the data.
      It converts the 'values' array into a normal format, that looks like this:
          {
              x: (raw x value, or an index if ordinal=true)
              y: (the raw y value)
              data: (reference to the original data point)
          }
      
      It also adds an 'extent' property to the series data.
      
      @param data - the chart data to normalize.
      @param options - object with the following properties:
          getX: function to get the raw x value
          getY: function to get the raw y value
          ordinal: boolean describing whether the data is uniformly distributed
              on the x-axis or not.
       */
      normalize: function(data, options) {
        var colorIndex, colorPalette, getX, getY, ordinal, seriesIndex;
        if (options == null) {
          options = {};
        }
        data = this.clone(data);
        getX = options.getX;
        getY = options.getY;
        ordinal = options.ordinal;
        colorPalette = options.colorPalette || colors20;
        colorIndex = 0;
        seriesIndex = 0;
        data.forEach(function(series, i) {
          if (series.key == null) {
            series.key = "series" + i;
          }
          if (series.label == null) {
            series.label = "Series #" + i;
          }
          if (series.type == null) {
            series.type = series.value != null ? 'marker' : 'scatter';
          }
          if (series.type === 'region') {
            series.extent = {
              x: series.axis === 'x' ? series.values : [],
              y: series.axis !== 'x' ? series.values : []
            };
            return;
          }
          if (series.type === 'marker') {
            series.extent = {
              x: series.axis === 'x' ? [series.value] : [],
              y: series.axis !== 'x' ? [series.value] : []
            };
            return;
          }
          if (series.color == null) {
            series.color = colorPalette[colorIndex % colorPalette.length];
            colorIndex++;
          }
          series.index = seriesIndex;
          seriesIndex++;
          if (series.values instanceof Array) {
            series.isDataSeries = true;
            return series.values = series.values.map(function(d, i) {
              return {
                x: ordinal ? i : getX(d, i),
                y: getY(d, i),
                data: d
              };
            });
          }
        });

        /*
        Calculates the extent (in x and y directions) of the data in each
        series. The 'extent' is basically the highest and lowest values, used
        to figure out the chart's scale.
        
        Special attention is given when 'stackable' is true. In that case,
        we need to add y0 to y, because the data is stacked, therefore the
        extent must be bigger.
         */
        data.forEach(function(series) {
          if (series.isDataSeries) {
            return series.extent = {
              x: d3.extent(series.values, function(d) {
                return d.x;
              }),
              y: d3.extent(series.values, function(d) {
                return d.y;
              })
            };
          }
        });
        return data;
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
      hide: function(keys, flag) {
        var d, j, len, ref;
        if (flag == null) {
          flag = true;
        }
        if (!(keys instanceof Array)) {
          keys = [keys];
        }
        for (j = 0, len = data.length; j < len; j++) {
          d = data[j];
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
        var d, j, len, ref;
        if (!(keys instanceof Array)) {
          keys = [keys];
        }
        for (j = 0, len = data.length; j < len; j++) {
          d = data[j];
          if (ref = d.key, indexOf.call(keys, ref) >= 0) {
            d.hidden = !d.hidden;
          }
        }
        return this;
      },
      showOnly: function(key, options) {
        var d, j, len;
        if (options == null) {
          options = {};
        }
        if (options.onlyDataSeries == null) {
          options.onlyDataSeries = false;
        }
        for (j = 0, len = data.length; j < len; j++) {
          d = data[j];
          if (options.onlyDataSeries && !d.isDataSeries) {
            continue;
          }
          d.hidden = !(d.key === key);
        }
        return this;
      },
      showAll: function() {
        var d, j, len;
        for (j = 0, len = data.length; j < len; j++) {
          d = data[j];
          d.hidden = false;
        }
        return this;
      },
      visible: function() {
        return data.filter(function(d) {
          return !d.hidden;
        });
      },
      _getSliceable: function() {
        return data.filter(function(d) {
          return d.isDataSeries;
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
        return this._xValues(chart.getXInternal);
      },
      xValuesRaw: function() {
        var getX;
        getX = function(d, i) {
          return chart.getX()(d.data, i);
        };
        return this._xValues(getX);
      },
      xValueAt: function(i) {
        var dataObjs, point;
        dataObjs = this._getSliceable();
        if (dataObjs[0] == null) {
          return null;
        }
        point = dataObjs[0].values[i];
        if (point != null) {
          return chart.getX()(point.data);
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
          return !d.hidden;
        }).map(function(d) {
          var point;
          point = d.values[idx];
          return {
            x: chart.getX()(point.data, idx),
            y: chart.getY()(point.data, idx),
            key: d.key,
            label: d.label,
            color: d.color
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
          return !d.hidden;
        }).map(function(s, i) {
          return s.values.map(function(point, i) {
            point.series = s;
            point.xValue = chart.getX()(point.data, i);
            return point;
          });
        });
        allPoints = d3.merge(allPoints);
        return d3.geom.quadtree().x(chart.getXInternal).y(chart.getYInternal)(allPoints);
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
  var Legend, legendProperties;

  legendProperties = [['onlyDataSeries', true]];

  this.ForestD3.Legend = Legend = (function() {
    function Legend(domContainer) {
      var processClickEvent;
      this.name = 'legend';
      this.properties = {};
      ForestD3.Utils.setProperties(this, this.properties, legendProperties);
      if (domContainer.select != null) {
        this.container = domContainer;
      } else {
        this.container = d3.select(domContainer);
      }
      this.container.classed('forest-d3 legend', true);

      /*
      This is a technique to distinguish between single and double clicks.
      
      When any kind of click happens, the last event handler gets stored in
      @lastClickEvent.
      
      After a brief delay of about 200 ms, the lastClickEvent is executed.
       */
      this.lastClickEvent = function() {};
      processClickEvent = (function(_this) {
        return function() {
          return _this.lastClickEvent.call(_this);
        };
      })(this);
      this.legendClickHandler = ForestD3.Utils.debounce(processClickEvent, 200);
    }

    Legend.prototype.chart = function(chart) {
      this.chartInstance = chart;
      return this;
    };

    Legend.prototype.destroy = function() {
      if (this.container != null) {
        return this.container.remove();
      }
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
      data = this.chartInstance.data().get();
      if (this.onlyDataSeries()) {
        data = data.filter(function(d) {
          return d.isDataSeries;
        });
      }
      items = this.container.selectAll('div.item').data(data, function(d) {
        return d.key;
      });
      itemsEnter = items.enter().append('div').classed('item', true);
      items.on('click.legend', (function(_this) {
        return function(d) {
          _this.lastClickEvent = function() {
            return _this.chartInstance.data().toggle(d.key).render();
          };
          return _this.legendClickHandler();
        };
      })(this)).on('dblclick.legend', (function(_this) {
        return function(d) {
          _this.lastClickEvent = function() {
            return _this.chartInstance.data().showOnly(d.key, {
              onlyDataSeries: _this.onlyDataSeries()
            }).render();
          };
          return _this.legendClickHandler();
        };
      })(this)).on('mouseover.legend', (function(_this) {
        return function(d) {
          return _this.chartInstance.highlightSeries(d.key);
        };
      })(this)).on('mouseout.legend', (function(_this) {
        return function(d) {
          return _this.chartInstance.highlightSeries(null);
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
      return itemsEnter.append('span').classed('show-only button', true).text('only').on('click.showOnly', (function(_this) {
        return function(d) {
          d3.event.stopPropagation();
          return _this.chartInstance.data().showOnly(d.key, {
            onlyDataSeries: _this.onlyDataSeries()
          }).render();
        };
      })(this));
    };

    return Legend;

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


    /*
    canvasMouse: the pixel coordinates on the chart canvas to draw the
    cross hairs. Array of [x,y] values.
     */

    Crosshairs.prototype.render = function(canvasMouse) {
      var x, y;
      if (!this.chart.showGuideline()) {
        return;
      }
      if (this.xLine == null) {
        return;
      }
      x = canvasMouse[0], y = canvasMouse[1];
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
    single: function(chart, point, options) {
      var bgColor, color, getXValue, label, series, xValue;
      if (options == null) {
        options = {};
      }
      getXValue = options.getXValue || chart.getXInternal;
      series = options.series || {};
      xValue = chart.xTickFormat()(getXValue(point));
      color = series.color;
      bgColor = "background-color: " + color + ";";
      label = series.label || series.key;
      return "<div class='header'>" + xValue + "</div>\n<table>\n    <tr>\n        <td><div class='series-color' style='" + bgColor + "'></div></td>\n        <td class='series-label'>" + label + "</td>\n        <td class='series-value'>\n            " + (chart.yTickFormat()(chart.getYInternal(point))) + "\n        </td>\n    </tr>\n</table>";
    }
  };

}).call(this);

(function() {
  var Tooltip;

  this.ForestD3.Tooltip = Tooltip = (function() {
    function Tooltip() {
      this.container = null;
    }


    /*
    Lets you define a DOM id for the tooltip. Makes it so that
    you can perform DOM manipulation on it later on.
     */

    Tooltip.prototype.id = function(s) {
      if (arguments.length === 0) {
        return this._id;
      } else {
        this._id = s;
        return this;
      }
    };


    /*
    content: string or DOM object or d3 object representing tooltip content.
    clientMouse: Array of [mouse screen x, mouse screen y] positions
     */

    Tooltip.prototype.render = function(content, clientMouse) {
      var containerCenter, dimensions, edgeThreshold, xPos, yPos;
      if (!(clientMouse instanceof Array)) {
        console.warn('ForestD3.Tooltip.render: clientMouse not present.');
        return;
      }
      if (this.container == null) {
        this.container = document.createElement('div');
        document.body.appendChild(this.container);
      }
      if (content == null) {
        content = '';
      }
      if ((typeof content) !== 'string') {
        content = content.toString();
      }
      d3.select(this.container).classed('forest-d3 tooltip-box', true).html(content);

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
      return d3.select(this.container).attr('id', this.id()).style('left', xPos + "px").style('top', yPos + "px").transition().style('opacity', 0.9);
    };

    Tooltip.prototype.hide = function() {
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
A Chart object renders time series data, or scatter plot data.

You can combine lines, bars, areas and scatter points into one chart.
 */

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
    ], ['forceDomain', null], ['ordinal', true], ['autoResize', true], ['colorPalette', null], ['duration', 250], ['pointSize', 4], ['xPadding', 0.1], ['yPadding', 0.1], ['xLabel', ''], ['yLabel', ''], ['chartLabel', ''], ['xScaleType', d3.scale.linear], ['yScaleType', d3.scale.linear], [
      'xTickFormat', function(d) {
        return d;
      }
    ], ['yTickFormat', d3.format(',.2f')], ['reduceXTicks', true], ['yTicks', null], ['showXAxis', true], ['showYAxis', true], ['showTooltip', true], ['showGuideline', true], ['tooltipType', 'bisect'], ['barPaddingPercent', 0.1]
  ];

  this.ForestD3.Chart = Chart = (function(superClass) {
    extend(Chart, superClass);

    function Chart(domContainer) {
      Chart.__super__.constructor.call(this, domContainer);
      this._setProperties(chartProperties);
      this.tooltip = new ForestD3.Tooltip();
      this.guideline = new ForestD3.Guideline(this);
      this.crosshairs = new ForestD3.Crosshairs(this);
      this.xAxis = d3.svg.axis();
      this.yAxis = d3.svg.axis();
      this.getXInternal = function(d) {
        return d.x;
      };
      this.getYInternal = function(d) {
        return d.y;
      };
      this._tooltipFrozen = false;
    }

    Chart.prototype.destroy = function() {
      Chart.__super__.destroy.call(this);
      this.tooltip.destroy();
      return this.destroyPlugins();
    };


    /*
    Set chart data.
     */

    Chart.prototype.data = function(d) {
      if (arguments.length === 0) {
        return ForestD3.DataAPI.call(this, this.chartData);
      } else {
        this.chartData = ForestD3.Utils.normalize(d, {
          getX: this.getX(),
          getY: this.getY(),
          ordinal: this.ordinal(),
          colorPalette: this.colorPalette()
        });
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
      var chart, chartSeries;
      if (this.svg == null) {
        return this;
      }
      if (this.chartData == null) {
        return this;
      }
      this.updateDimensions();
      this.updateChartScale();
      this.updateChartFrame();
      chartSeries = this.canvas.selectAll('g.series').data(this.data().visible(), function(series) {
        return series.key;
      });
      chartSeries.enter().append('g').attr('class', function(series, i) {
        return "series series-" + series.key;
      });
      chartSeries.exit().transition().duration(this.duration()).style('opacity', 0).remove();
      chart = this;

      /*
      Main render loop. Loops through the data array, and depending on the
      'type' attribute, renders a different kind of chart element.
       */
      chartSeries.each(function(series, i) {
        var seriesContainer, visualization;
        seriesContainer = d3.select(this);
        visualization = chart.getVisualization(series);
        return visualization.call(chart, seriesContainer, series);
      });

      /*
      This line keeps chart-items in order on the canvas. Items that appear
      lower in the list thus overlap items that are near the beginning of the
      list.
       */
      chartSeries.order();
      this.renderPlugins();
      this.trigger('rendered');
      return this;
    };


    /*
    Given a chart series object, determines what type of visualization
    to render.
     */

    Chart.prototype.getVisualization = function(series) {
      var visualizations;
      visualizations = ForestD3.Visualizations;
      switch (series.type) {
        case 'scatter':
          return visualizations.scatter;
        case 'line':
          return visualizations.line;
        case 'bar':
          return visualizations.bar;
        case 'ohlc':
          return visualizations.ohlc;
        case 'marker':
          return visualizations.markerLine;
        case 'region':
          return visualizations.region;
        default:
          return function() {
            return 0;
          };
      }
    };


    /*
    Applies the CSS class 'highlight' to a specific series <g> element.
    key - string representing the series key
     */

    Chart.prototype.highlightSeries = function(key) {
      return this.canvas.selectAll('g.series').classed('highlight', function(series) {
        return series.key === key;
      });
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

        /*
        Calculates the chart canvas dimensions. Uses the parent
        container's dimensions, and subtracts off any margins.
         */
        this.canvasHeight = this.height - margin.bottom - margin.top;
        this.canvasWidth = this.width - margin.left - margin.right;
        this.canvasWidth = d3.max([this.canvasWidth, 50]);
        return this.canvasHeight = d3.max([this.canvasHeight, 50]);
      }
    };


    /*
    Draws the chart frame:
    * Canvas <rect>
    * X and Y Axes
    * Guidelines
    * Labels
     */

    Chart.prototype.updateChartFrame = function() {
      var axesLabels, backdrop, canvasEnter, chart, chartLabel, margin, tickValues, xAxisGroup, xAxisLabel, xValues, xValuesRaw, yAxisGroup, yAxisLabel;
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
          xValues = this.data().xValues();
          tickValues = (function(_this) {
            return function() {
              var widthThreshold, xTickWidth, xTicks;
              if (_this.reduceXTicks()) {
                xTickWidth = ForestD3.Utils.textWidthApprox(xValuesRaw, _this.xTickFormat());
                xTicks = _this.canvasWidth / xTickWidth;
                widthThreshold = Math.ceil(_this.xScale.invert(xTickWidth));
                return ForestD3.Utils.tickValues(xValues, xTicks, widthThreshold);
              } else {
                return xValues;
              }
            };
          })(this)();
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
      }).on('click', function() {
        return chart._tooltipFrozen = !chart._tooltipFrozen;
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


    /*
    Gives sub-charts a chance to pre-process the data.
    
    For example, stacked charts will want to call d3.layout.stack() before
    calculating the extent.
    
    Defaults to no-op.
     */

    Chart.prototype.preprocessData = function() {};


    /*
    Creates an x and y scale, setting the domain and ranges.
     */

    Chart.prototype.updateChartScale = function() {
      var extent;
      this.preprocessData();
      extent = ForestD3.Utils.extent(this.data().visible(), this.forceDomain());
      extent = ForestD3.Utils.extentPadding(extent, {
        x: this.xPadding(),
        y: this.yPadding()
      });
      this.yScale = this.yScaleType()().domain(extent.y).range([this.canvasHeight, 0]);
      return this.xScale = this.xScaleType()().domain(extent.x).range([0, this.canvasWidth]);
    };


    /*
    Updates where the guideline and tooltip is.
    
    canvasMouse: array: [x,y] - location of mouse in canvas
    clientMouse: array: [x,y] - location of mouse in browser
     */

    Chart.prototype.updateTooltip = function(canvasMouse, clientMouse) {
      var content, dist, idx, isHidden, point, threshold, x, xActual, xDiff, xPos, xValues, y, yActual, yDiff, yPos;
      if (!this.showTooltip()) {
        return;
      }
      if (this._tooltipFrozen) {
        return;
      }
      if (canvasMouse == null) {
        this.guideline.hide();
        this.crosshairs.hide();
        return this.tooltip.hide();
      } else {
        xPos = canvasMouse[0], yPos = canvasMouse[1];
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
          isHidden = point.series.hidden;
          if (dist < threshold && !isHidden) {
            content = ForestD3.TooltipContent.single(this, point, {
              getXValue: function(d) {
                return d.xValue;
              },
              series: point.series
            });
            return this.renderSpatialTooltip({
              content: content,
              clientMouse: clientMouse,
              canvasMouse: [xActual, yActual]
            });
          } else {
            return this.renderSpatialTooltip({
              hide: true
            });
          }
        }
      }
    };


    /*
    Special function to show/hide a spatial tooltip.
    This kind of tooltip has a crosshair as well as the floating tooltip box.
    
    Used for scatter charts primarily, but can be used for anything.
    Best for showing a single point of data.
    
    Options you can pass in:
        content - string representing the tooltip content body (HTML)
        clientMouse - [x,y] coordinates of the mouse location in browser.
        canvasMouse - [x,y] coordinates of mouse in chart canvas
        hide - boolean. If true, the tooltips are removed.
     */

    Chart.prototype.renderSpatialTooltip = function(options) {
      if (options == null) {
        options = {};
      }
      if (options.hide) {
        this.tooltip.hide();
        return this.crosshairs.hide();
      } else {
        this.tooltip.render(options.content, options.clientMouse);
        return this.crosshairs.render(options.canvasMouse);
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

    Chart.prototype.destroyPlugins = function() {
      var key, plugin, ref, results;
      ref = this.plugins;
      results = [];
      for (key in ref) {
        plugin = ref[key];
        if (plugin.destroy != null) {
          results.push(plugin.destroy());
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
      this.getXInternal = function(d) {
        return d.x;
      };
      this.getYInternal = function(d) {
        return d.y;
      };
    }


    /*
    Set chart data.
     */

    BarChart.prototype.data = function(d) {
      if (d == null) {
        return ForestD3.DataAPI.call(this, this.chartData);
      } else {
        this.chartData = ForestD3.Utils.normalize(d, {
          getX: this.getX(),
          getY: this.getY(),
          ordinal: true
        });
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
          return d3.ascending(getVal(a.data), getVal(b.data));
        });
      } else {
        result.sort(function(a, b) {
          return d3.descending(getVal(a.data), getVal(b.data));
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
          return _this.getX()(d.data, i);
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
      labels = this.labelGroup.selectAll('text').data(this._barDataSorted(), this.getXInternal);
      labels.enter().append('text').attr('text-anchor', 'end').attr('x', 0).attr('y', 0).style('fill-opacity', 0);
      labels.exit().remove();
      labels.each(function(d, i) {
        var isNegative;
        isNegative = chart.getYInternal(d) < 0;
        return d3.select(this).classed('positive', !isNegative).classed('negative', isNegative).text(chart.getX()(d.data, i)).transition().duration(700).delay(i * 20).attr('y', barY(i)).style('fill-opacity', 1);
      });
      zeroPosition = chart.yScale(0);
      bars = this.barGroup.selectAll('rect').data(this._barDataSorted(), this.getXInternal);
      bars.enter().append('rect').attr('x', zeroPosition).attr('y', 0).style('fill-opacity', 0).style('stroke-opacity', 0);
      bars.exit().remove();
      bars.each(function(d, i) {
        var isNegative, translate, width;
        width = (function() {
          var yPos;
          yPos = chart.yScale(chart.getYInternal(d));
          return Math.abs(yPos - zeroPosition);
        })();
        isNegative = chart.getYInternal(d) < 0;
        translate = isNegative ? "translate(" + (-width) + ", 0)" : '';
        return d3.select(this).attr('height', chart.barHeight()).attr('transform', translate).classed('positive', !isNegative).classed('negative', isNegative).transition().attr('width', width).style('fill', color).duration(700).delay(i * 50).attr('x', zeroPosition).attr('y', barY(i)).style('fill-opacity', 1).style('stroke-opacity', 0.7);
      });
      valueLabels = this.valueGroup.selectAll('text').data(this._barDataSorted(), this.getXInternal);
      valueLabels.enter().append('text').attr('x', 0);
      valueLabels.exit().remove();
      valueLabels.each(function(d, i) {
        var isNegative, xPos, yVal;
        yVal = chart.getYInternal(d, i);
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
      extent = ForestD3.Utils.extent(this.data().get(), {
        y: 0
      });
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


/*
A StackedChart is responsible for rendering a chart with 'layers'.
Examples include stacked bar and stacked area charts.

Due to the unique nature of the stacked visualization, you are not
allowed to combine it with lines and scatters.
 */

(function() {
  var StackedChart, chartProperties,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  chartProperties = [['stackType', 'bar'], ['stacked', true]];

  this.ForestD3.StackedChart = StackedChart = (function(superClass) {
    extend(StackedChart, superClass);

    function StackedChart(domContainer) {
      StackedChart.__super__.constructor.call(this, domContainer);
      this._setProperties(chartProperties);
    }

    StackedChart.prototype.preprocessData = function() {
      var internalData, seriesType, yOffsetVal;
      internalData = this.data().visible().filter(function(d) {
        return d.isDataSeries;
      });
      d3.layout.stack().offset('zero').values(function(d) {
        return d.values;
      })(internalData);
      yOffsetVal = this.stacked() ? function(d) {
        return d.y + d.y0;
      } : function(d) {
        return d.y;
      };
      seriesType = 'bar';
      return internalData.forEach(function(series) {
        var yVals;
        if (series.isDataSeries) {
          series.type = seriesType;
          yVals = series.values.map(yOffsetVal);

          /*
          Add 0 to the extent always, because stacked bar charts
          should be based on the zero axis
           */
          yVals = yVals.concat([0]);
          return series.extent.y = d3.extent(yVals);
        }
      });
    };


    /*
    Override the parent class' method.
     */

    StackedChart.prototype.getVisualization = function(series) {
      var renderFn;
      renderFn = StackedChart.__super__.getVisualization.call(this, series);
      if (series.type === 'bar') {
        if (this.stacked()) {
          return ForestD3.Visualizations.barStacked;
        } else {
          return ForestD3.Visualizations.bar;
        }
      } else {
        return renderFn;
      }
    };

    return StackedChart;

  })(ForestD3.Chart);

}).call(this);
