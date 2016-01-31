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
        series = options.series or {}
        color = series.color
        bgColor = "background-color: #{color};"
        label = series.label or series.key

        """
        <div class='header'>#{chart.xTickFormat()(point.xValueRaw)}</div>
        <table>
            <tr>
                <td><div class='series-color' style='#{bgColor}'></div></td>
                <td class='series-label'>#{label}</td>
                <td class='series-value'>
                    #{chart.yTickFormat()(point.yValueRaw)}
                </td>
            </tr>
        </table>
        """