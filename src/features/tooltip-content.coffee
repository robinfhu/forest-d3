###
Library of tooltip rendering utilities
###
@ForestD3.TooltipContent =
    multiple: (xValue, points)->
        rows = points.map (d)->
            bgColor = "background-color: #{d.series.color};"
            """
                <tr>
                    <td><div class='series-color' style='#{bgColor}'></div></td>
                    <td class='series-label'>
                        #{d.series.label or d.series.key}
                    </td>
                    <td class='series-value'>#{d.yFormatted}</td>
                </tr>
            """

        rows = rows.join ''

        """
        <div class='header'>#{xValue}</div>
        <table>
            #{rows}
        </table>
        """

    single: (chart, point)->
        series = point.series
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