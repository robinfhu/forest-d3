###
********************************************************
Forest D3 - a charting library using d3.js

Author:  Robin Hu

********************************************************
###
unless d3?
    throw new Error """
    d3.js has not been included. See http://d3js.org/ for how to include it.
    """

@ForestD3 =
    version: '0.4.0-beta'

@ForestD3.Visualizations = {}