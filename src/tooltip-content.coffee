###
Library of tooltip rendering utilities
###
@ForestD3.TooltipContent =
    multiple: (chart, xIndex)->
        xValue = chart.data().xValueAt xIndex
        xValue = chart.xTickFormat()(xValue)

        slice = chart.data().sliced xIndex

        rows = slice.map (d)->
            bgColor = "background-color: #{d.color}"
            """
                <tr>
                    <td><div class='series-color' style='#{bgColor}'></div></td>
                    <td class='series-label'>#{d.label}</td>
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