###
Library of tooltip rendering utilities
###
@ForestD3.TooltipContent =
    multiple: (chart, xIndex)->
        xValue = chart.data().xValueAt xIndex
        xValue = chart.xTickFormat()(xValue)

        slice = chart.data().sliced xIndex

        """
        <div class='header'>#{xValue}</div>
        """