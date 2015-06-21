
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
    fullSpace -= d3.min([fullSpace / 2, maxPadding]);
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
    return bars.transition().delay(function(d, i) {
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
    var area, areaBase, areaFn, chart, interpolate, lineFn, path, x, y;
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
    path.transition().duration(800).attr('d', lineFn.y(function(d, i) {
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
      return area.transition().duration(800).style('fill', chart.seriesColor(selectionData)).attr('d', areaFn.y1(function(d, i) {
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
    var chart, label, labelEnter, labelOffset, labelPadding, labelRotate, line, x, y;
    chart = this;
    line = selection.selectAll('line.marker').data(function(d) {
      return [d.value];
    });
    label = selection.selectAll('text.marker-label').data([selectionData.label]);
    labelEnter = label.enter().append('text').classed('marker-label', true).text(function(d) {
      return d;
    }).attr('x', 0).attr('y', 0);
    labelPadding = 10;
    if (selectionData.axis === 'x') {
      x = chart.xScale(selectionData.value);
      line.enter().append('line').classed('marker', true).attr('x1', 0).attr('x2', 0).attr('y1', 0);
      line.attr('y2', chart.canvasHeight).transition().attr('x1', x).attr('x2', x);
      labelRotate = "rotate(-90 " + x + " " + chart.canvasHeight + ")";
      labelOffset = "translate(0 " + (-labelPadding) + ")";
      labelEnter.attr('transform', labelRotate);
      return label.attr('y', chart.canvasHeight).transition().attr('transform', labelRotate + " " + labelOffset).attr('x', x);
    } else {
      y = chart.yScale(selectionData.value);
      line.enter().append('line').classed('marker', true).attr('x1', 0).attr('y1', 0).attr('y2', 0);
      line.attr('x2', chart.canvasWidth).transition().attr('y1', y).attr('y2', y);
      return label.attr('text-anchor', 'end').transition().attr('x', chart.canvasWidth).attr('y', y + labelPadding);
    }
  };

}).call(this);

(function() {
  this.ForestD3.ChartItem.ohlc = function(selection, selectionData) {
    var chart, close, closeMarks, hi, lo, open, openMarks, rangeLines, x;
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
    rangeLines.enter().append('line').classed('ohlc-range', true).attr('x1', function(d, i) {
      return chart.xScale(x(d, i));
    }).attr('x2', function(d, i) {
      return chart.xScale(x(d, i));
    }).attr('y1', 0).attr('y2', 0);
    rangeLines.exit().remove();
    rangeLines.transition().delay(function(d, i) {
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
    openMarks.transition().delay(function(d, i) {
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
    return closeMarks.transition().delay(function(d, i) {
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
    var chart, end, height, region, regionEnter, start, width, x, y;
    chart = this;
    region = selection.selectAll('rect.region').data([selectionData]);
    regionEnter = region.enter().append('rect').classed('region', true);
    start = d3.min(selectionData.values);
    end = d3.max(selectionData.values);
    if (selectionData.axis === 'x') {
      x = chart.xScale(start);
      width = Math.abs(chart.xScale(start) - chart.xScale(end));
      regionEnter.attr('width', 0);
      return region.attr('x', x).attr('y', 0).attr('height', chart.canvasHeight).transition().attr('width', width);
    } else {
      y = chart.yScale(end);
      height = Math.abs(chart.yScale(start) - chart.yScale(end));
      regionEnter.attr('height', 0);
      return region.attr('x', 0).attr('y', y).transition().attr('width', chart.canvasWidth).attr('height', height);
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
    var chart, points, x, y;
    chart = this;
    selection.style('fill', chart.seriesColor);
    points = selection.selectAll('circle.point').data(function(d) {
      return d.values;
    });
    x = chart.getXInternal();
    y = chart.getY();
    points.enter().append('circle').classed('point', true).attr('cx', chart.canvasWidth / 2).attr('cy', chart.canvasHeight / 2).attr('r', 0);
    points.exit().remove();
    return points.transition().delay(function(d, i) {
      return i * 10;
    }).ease('quad').attr('cx', function(d, i) {
      return chart.xScale(x(d, i));
    }).attr('cy', function(d, i) {
      return chart.yScale(y(d, i));
    }).attr('r', chart.pointSize());
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
      Adds a numeric _index to each series, which is used to uniquely
      identify it.
       */
      indexify: function(data) {
        return data.map(function(d, i) {
          d._index = i;
          return d;
        });
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
      }
    };
  })();

}).call(this);

(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  this.ForestD3.DataAPI = function(data) {
    var chart, getIdx;
    chart = this;
    getIdx = function(d, i) {
      return i;
    };
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
      showOnly: function(key) {
        var d, j, len;
        for (j = 0, len = data.length; j < len; j++) {
          d = data[j];
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
          return !d.hidden;
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
        bgColor = "background-color: " + d.color;
        return "<tr>\n    <td><div class='series-color' style='" + bgColor + "'></div></td>\n    <td class='series-label'>" + d.label + "</td>\n    <td class='series-value'>" + (chart.yTickFormat()(d.y)) + "</td>\n</tr>";
      });
      rows = rows.join('');
      return "<div class='header'>" + xValue + "</div>\n<table>\n    " + rows + "\n</table>";
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
      var containerCenter, xPos, yPos;
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
      containerCenter = this.container.getBoundingClientRect().height / 2;
      yPos -= containerCenter;
      return d3.select(this.container).style('left', xPos + "px").style('top', yPos + "px").transition().style('opacity', 0.9);
    };

    Tooltip.prototype.hide = function() {
      if (!this.chart.showTooltip()) {
        return;
      }
      return d3.select(this.container).transition().delay(250).style('opacity', 0);
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

(function() {
  var Chart, chartProperties, getIdx;

  chartProperties = [
    [
      'getX', function(d, i) {
        return d[0];
      }
    ], [
      'getY', function(d, i) {
        return d[1];
      }
    ], ['ordinal', false], ['autoResize', true], ['color', ForestD3.Utils.defaultColor], ['pointSize', 4], ['xPadding', 0.1], ['yPadding', 0.1], ['xLabel', ''], ['yLabel', ''], [
      'xTickFormat', function(d) {
        return d;
      }
    ], ['yTickFormat', d3.format(',.2f')], ['showTooltip', true], ['showGuideline', true]
  ];

  getIdx = function(d, i) {
    return i;
  };

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
      this.tooltip = new ForestD3.Tooltip(this);
      this.guideline = new ForestD3.Guideline(this);
      this.xAxis = d3.svg.axis();
      this.yAxis = d3.svg.axis();
      this.seriesColor = (function(_this) {
        return function(d) {
          return d.color || _this.color()(d._index);
        };
      })(this);
      this.getXInternal = (function(_this) {
        return function() {
          if (_this.ordinal()) {
            return getIdx;
          } else {
            return _this.getX();
          }
        };
      })(this);
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
    }


    /*
    Call this method to remove chart from the document and any artifacts
    it has (like tooltips) and event handlers.
     */

    Chart.prototype.destroy = function() {
      var domContainer;
      domContainer = this.container();
      if ((domContainer != null ? domContainer.parentNode : void 0) != null) {
        domContainer.parentNode.removeChild(domContainer);
      }
      this.tooltip.destroy();
      return window.removeEventListener('resize', this.resize);
    };


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
      chartItems.exit().transition().style('opacity', 0).remove();
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
      var axesLabels, backdrop, canvasEnter, chart, xAxisGroup, xAxisLabel, xTicks, xValues, yAxisGroup, yAxisLabel;
      backdrop = this.svg.selectAll('rect.backdrop').data([0]);
      backdrop.enter().append('rect').classed('backdrop', true);
      backdrop.attr('width', this.width).attr('height', this.height);
      xTicks = Math.abs(this.xScale.range()[0] - this.xScale.range()[1]) / 100;
      xValues = this.data().xValuesRaw();
      this.xAxis.scale(this.xScale).tickSize(10, 10).ticks(xTicks).tickPadding(5).tickFormat((function(_this) {
        return function(d) {
          var tick;
          tick = _this.ordinal() ? xValues[d] : d;
          return _this.xTickFormat()(tick, d);
        };
      })(this));
      xAxisGroup = this.svg.selectAll('g.x-axis').data([0]);
      xAxisGroup.enter().append('g').attr('class', 'x-axis axis');
      xAxisGroup.attr('transform', "translate(" + this.margin.left + ", " + (this.canvasHeight + this.margin.top) + ")");
      this.yAxis.scale(this.yScale).orient('left').tickSize(-this.canvasWidth, 10).tickPadding(10).tickFormat(this.yTickFormat());
      yAxisGroup = this.svg.selectAll('g.y-axis').data([0]);
      yAxisGroup.enter().append('g').attr('class', 'y-axis axis');
      yAxisGroup.attr('transform', "translate(" + this.margin.left + ", " + this.margin.top + ")");
      xAxisGroup.transition().call(this.xAxis);
      yAxisGroup.transition().call(this.yAxis);
      this.canvas = this.svg.selectAll('g.canvas').data([0]);
      canvasEnter = this.canvas.enter().append('g').classed('canvas', true);
      this.canvas.attr('transform', "translate(" + this.margin.left + ", " + this.margin.top + ")");
      canvasEnter.append('rect').classed('canvas-backdrop', true);
      chart = this;
      this.canvas.select('rect.canvas-backdrop').attr('width', this.canvasWidth).attr('height', this.canvasHeight).on('mousemove', function() {
        return chart.updateTooltip(d3.mouse(this), [d3.event.clientX, d3.event.clientY]);
      }).on('mouseout', function() {
        return chart.updateTooltip(null);
      });
      this.guideline.create(this.canvas);
      axesLabels = this.canvas.selectAll('g.axes-labels').data([0]);
      axesLabels.enter().append('g').classed('axes-labels', true);
      xAxisLabel = axesLabels.selectAll('text.x-axis').data([this.xLabel()]);
      xAxisLabel.enter().append('text').classed('x-axis', true).attr('text-anchor', 'end').attr('x', 0).attr('y', this.canvasHeight);
      xAxisLabel.text(function(d) {
        return d;
      }).transition().attr('x', this.canvasWidth);
      yAxisLabel = axesLabels.selectAll('text.y-axis').data([this.yLabel()]);
      yAxisLabel.enter().append('text').classed('y-axis', true).attr('text-anchor', 'end').attr('transform', 'translate(10,0) rotate(-90 0 0)');
      return yAxisLabel.text(function(d) {
        return d;
      });
    };

    Chart.prototype.updateChartScale = function() {
      var extent;
      extent = ForestD3.Utils.extent(this.data().visible(), this.getXInternal(), this.getY());
      extent = ForestD3.Utils.extentPadding(extent, {
        x: this.xPadding(),
        y: this.yPadding()
      });
      this.yScale = d3.scale.linear().domain(extent.y).range([this.canvasHeight, 0]);
      return this.xScale = d3.scale.linear().domain(extent.x).range([0, this.canvasWidth]);
    };


    /*
    Updates where the guideline and tooltip is.
    
    mouse should be an array of two things: [mouse x , mouse y]
     */

    Chart.prototype.updateTooltip = function(mouse, clientMouse) {
      var content, idx, xPos, xValues, yPos;
      if (mouse == null) {
        this.guideline.hide();
        return this.tooltip.hide();
      } else {
        xPos = mouse[0], yPos = mouse[1];
        xValues = this.data().xValues();
        idx = ForestD3.Utils.smartBisect(xValues, this.xScale.invert(xPos), function(d) {
          return d;
        });
        xPos = this.xScale(xValues[idx]);
        this.guideline.render(xPos, idx);
        content = ForestD3.TooltipContent.multiple(this, idx);
        return this.tooltip.render(content, clientMouse);
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

  })();

}).call(this);
