###
Library of tooltip rendering utilities
###
@ForestD3.TooltipContent =
    multiple: (chart, xIndex)->
        xValue = chart.data().xValueAt xIndex
        xValue = chart.xTickFormat()(xValue)

        slice = chart.data().sliced xIndex

        rows = slice.map (d)->
            bgColor = "background-color: #{d.color};"
            """
                <tr>
                    <td><div class='series-color' style='#{bgColor}'></div></td>
                    <td class='series-label'>#{d.label or d.key}</td>
                    <td class='series-value'>#{chart.yTickFormat()(d.y)}</td>
                </tr>
            """

        rows = rows.join ''

        """
        <div class='header'>#{xValue}</div>
        <table>
            #{rows}
        </table>
        """
    single: (chart, point, options={})->
        getXValue = options.getXValue or ((d)-> d.xValue)

        xValue = chart.xTickFormat()(getXValue(point))
        color = point.series.color
        bgColor = "background-color: #{color};"
        label = point.series.label or point.series.key
        """
        <div class='header'>#{xValue}</div>
        <table>
            <tr>
                <td><div class='series-color' style='#{bgColor}'></div></td>
                <td class='series-label'>#{label}</td>
                <td class='series-value'>
                    #{chart.yTickFormat()(chart.getYInternal(point))}
                </td>
            </tr>
        </table>
        """