import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WebTable extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;
  final List<TextAlign?>? headerAligns;
  final List<TextAlign?>? cellAligns;
  final double? minWidth;
  const WebTable({
    super.key,
    required this.headers,
    required this.rows,
    this.headerAligns,
    this.cellAligns,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    final has = rows.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth ?? 0),
          child: Table(
            columnWidths: {
              for (var i = 0; i < headers.length; i++)
                i: const IntrinsicColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: const BoxDecoration(color: AppColors.background),
                children: [
                  for (var i = 0; i < headers.length; i++)
                    _cell(
                      Text(
                        headers[i],
                        textAlign: _align(headerAligns, i),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      isHeader: true,
                    ),
                ],
              ),
              if (has)
                for (final row in rows)
                  TableRow(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    children: [
                      for (var i = 0; i < row.length; i++)
                        _cell(
                          DefaultTextStyle(
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: _align(cellAligns, i),
                            child: row[i],
                          ),
                          isHeader: false,
                        ),
                    ],
                  ),
              if (!has)
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Không có dữ liệu',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  TextAlign _align(List<TextAlign?>? aligns, int i) {
    if (aligns != null && i < aligns.length && aligns[i] != null) {
      return aligns[i]!;
    }
    return TextAlign.left;
  }

  Widget _cell(Widget child, {required bool isHeader}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: child,
    );
  }
}
