part of "../table.dart";

/// Adds a filter row to paginated widget rows.
List<List<Widget>> addFilter({
  required List<List<Widget>> rows,
  required List<Widget> filterRow,
  int rowsPerPage = 0,
}) {
  final List<List<Widget>> finalRow = [];
  if (filterRow.isNotEmpty) {
    rowsPerPage += 1;
  }
  for (var i = 0; i < rows.length; i++) {
    if (i % rowsPerPage == 0) {
      finalRow.add(filterRow);
    } else {
      finalRow.add(rows[i]);
    }
  }
  if (finalRow.last == filterRow) {
    finalRow.removeLast();
  }
  return finalRow;
}

/// Adds a filter row to paginated row models.
List<RowModel> addFilterForRowModel({
  required List<RowModel> rows,
  required RowModel filterRow,
  int rowsPerPage = 0,
}) {
  // Edge cases
  if (rowsPerPage <= 0) {
    // No pagination; prepend filter if it has content, else return rows as-is
    return filterRow.widget.isNotEmpty ? [filterRow, ...rows] : rows;
  }

  if (rows.isEmpty) {
    return filterRow.widget.isNotEmpty ? [filterRow] : [];
  }

  // If fewer rows than a page, just add filter at the start (when it is
  // non-empty)
  if (rows.length < rowsPerPage) {
    return filterRow.widget.isNotEmpty ? [filterRow, ...rows] : rows;
  }

  final List<RowModel> finalRows = [];

  // If filter has content, it consumes one slot in each page.
  // So the total slots per page = rowsPerPage (rows) + 1 (filter).
  final bool hasFilter = filterRow.widget.isNotEmpty;
  // final int totalSlotsPerPage = hasFilter ? rowsPerPage + 1 : rowsPerPage;

  // We'll track where we are within a page in terms of "row slots" (excluding
  // filter).
  int rowsInCurrentPage = 0;

  for (int i = 0; i < rows.length; i++) {
    // At the start of each page, add the filter if it exists.
    if (hasFilter && rowsInCurrentPage == 0) {
      finalRows.add(filterRow);
    }

    // Add the actual row
    finalRows.add(rows[i]);
    rowsInCurrentPage++;

    // Once we've added 'rowsPerPage' rows, we move to the next page.
    if (rowsInCurrentPage >= rowsPerPage) {
      rowsInCurrentPage = 0;
      // We do NOT add a trailing filter here; it will be added at the start of
      // the next page iteration.
    }
  }

  // If the very last element happens to be the filter (only possible when
  // rowsPerPage==0 or empty rows),
  // remove it to avoid trailing filter without content.
  if (finalRows.isNotEmpty &&
      finalRows.last == filterRow &&
      rowsInCurrentPage == 0) {
    finalRows.removeLast();
  }

  return finalRows;
}

/// A customizable raw table with pagination, filtering,
/// sorting, and stacked header support.
class CustomRawTable extends StatefulWidget {
  /// Creates a [CustomRawTable].
  CustomRawTable({
    required this.columns,
    super.key,
    this.initialPage,
    this.onPageChange,
    this.rows,
    this.rowModels,
    this.autoFitWidth = true,
    this.rowHeight = 38,
    this.isFilterTable = false,
    this.headerFontSize = AppStyle.fontSizeSmall,
    this.rowMinHeight,
    this.rowsPerPage,
    this.showPagination = true,
    this.headerColor,
    this.columnSpacing,
    this.showCurrencyValue = false,
    this.stackedHeaders,
    this.topStackedHeaders,
    this.topStackedHeaderHeight,
    this.columnHeaderHeight,
    this.stackedHeaderHeight,
    this.sortable = true,
  });

  ///[autoFitWidth] make the table width fits automatically to the respective
  ///screen width
  ///If [autoFitWidth] is false then we can control [columnSpacing] the width
  ///manually,
  ///But even if we assign column width and [autoFitWidth] is true, That
  ///[columnSpacing] won't be considered
  ///
  ///It won't works when we have [stackedHeaders] or [topStackedHeaders]
  /// Table columns.

  final List<TableColumn> columns;

  /// Table rows.
  final List<List<Widget>>? rows;

  /// Row models with optional styling.
  final List<RowModel>? rowModels;

  /// Automatically fits table width.
  final bool autoFitWidth;

  /// Row height.
  final double? rowHeight;

  /// Rows per page.
  int? rowsPerPage;

  /// Enables filter rows.
  final bool isFilterTable;

  /// Shows pagination controls.
  final bool showPagination;

  /// Header background color.
  final Color? headerColor;

  /// Column spacing.
  final double? columnSpacing;

  /// Shows currency formatting.
  final bool showCurrencyValue;

  /// Enables sorting.
  final bool sortable;

  /// Stacked headers.
  final List<StackedHeader>? stackedHeaders;

  /// Top stacked headers.
  final List<StackedHeader>? topStackedHeaders;

  /// Column header height.
  final double? columnHeaderHeight;

  /// Stacked header height.
  final double? stackedHeaderHeight;

  /// Header font size.
  final double? headerFontSize;

  /// Minimum row height.
  final double? rowMinHeight;

  /// Top stacked header height.
  final double? topStackedHeaderHeight;

  /// Initial page number.
  final int? initialPage;

  /// Page change callback.
  final Function(int)? onPageChange;

  @override
  State<CustomRawTable> createState() => _CustomRawTableState();
}

class _CustomRawTableState extends State<CustomRawTable> {
  late List<RowData> _rowData;
  late List<RowData> _filteredRows;
  final Map<int, bool> _selectionStates = {};
  int _currentPage = 0;
  List<StackedHeader> stackedHeaders = [];
  List<StackedHeader> stackedMainHeaders = [];
  final int defaultRowPerPage = 20;
  final ScrollController _scrollController = ScrollController();

  double mobileViewHeight = 40;
  double mobileViewWidth = 120;
  List totalCountWOFilter = [];

  @override
  void initState() {
    super.initState();
    _initializeData();

    if (widget.topStackedHeaders?.isNotEmpty ?? false) {
      _mapStackedMainHeadersToColumns(
        columns: widget.columns,
        headers: widget.topStackedHeaders ?? [],
      );
    }

    if (widget.stackedHeaders?.isNotEmpty ?? false) {
      _mapStackedHeadersToColumns(
        columns: widget.columns,
        headers: widget.stackedHeaders ?? [],
      );
    }

    // Set initial page if pagination is enabled
    if (widget.showPagination &&
        widget.rowsPerPage != null &&
        widget.initialPage != null) {
      _currentPage = widget.initialPage!.clamp(
        0,
        ((_filteredRows.length / widget.rowsPerPage!).ceil() - 1)
            .clamp(0, double.infinity)
            .toInt(),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onPageChange?.call(_currentPage);
        setState(() {});
      });
    }
  }

  Widget tableColumnWidget({
    required Widget child,
    required BoxConstraints constraints,
  }) {
    return (widget.stackedHeaders?.isEmpty ?? true) && (widget.autoFitWidth)
        ? ConstrainedBox(constraints: constraints, child: child)
        : child;
  }

  void _initializeData() {
    List<RowModel> rowModels = [];

    rowModels = widget.rowModels ??
        widget.rows!.map((row) {
          return RowModel(widget: row.toList(), isFilterRow: false);
        }).toList();

    _rowData = rowModels.map((row) {
      return RowData(
        id: UniqueKey().toString(),
        cells: List<Widget>.from(row.widget),
        rowColor: row.color,
        isFilterRow: row.isFilterRow,
        dropdownValues: List.filled(widget.columns.length, null),
      );
    }).toList();

    _filteredRows = List.from(_rowData);
    for (final data in _filteredRows) {
      if (!data.isFilterRow) {
        totalCountWOFilter.add(data);
      }
    }
    //for Table filter
    if (widget.isFilterTable && widget.rowsPerPage != null) {
      widget.rowsPerPage = widget.rowsPerPage! + 1;
    }

    _initializeTable();
  }

  void _initializeTable() {
    for (int i = 0; i < _filteredRows.length; i++) {
      _selectionStates[i] = false;
    }
  }

  Widget _cellWidget(Widget cell, int rowIndex, int colIndex) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: DefaultTextStyle.merge(
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: AppStyle.fontSizeSmall,
          color: AppColors.tablefontColor,
        ),
        child: cell,
      ),
    );
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    widget.onPageChange?.call(page);
  }

  void _handleHorizontalPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_scrollController.hasClients) {
      return;
    }

    final ScrollPosition position = _scrollController.position;
    if (position.maxScrollExtent <= 0) {
      return;
    }

    final double scrollDelta =
        event.scrollDelta.dx != 0 ? event.scrollDelta.dx : event.scrollDelta.dy;
    if (scrollDelta == 0) {
      return;
    }

    GestureBinding.instance.pointerSignalResolver.register(
      event,
      (PointerSignalEvent event) {
        final double offset = (_scrollController.offset + scrollDelta).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );
        _scrollController.jumpTo(offset);
      },
    );
  }

  List<StackedHeader> _removeStackedHeaderDuplicates(
    List<StackedHeader> stackedHeaders,
  ) {
    final Set<String> seen = <String>{};
    final List<StackedHeader> result = <StackedHeader>[];

    for (final StackedHeader header in stackedHeaders) {
      if (header.startIndex == -1) {
        result.add(header);
      } else {
        final String key = "${header.startIndex}-${header.endIndex}";
        if (seen.add(key)) {
          result.add(header);
        }
      }
    }

    return result;
  }

  bool ascending = true;

  void _mapStackedHeadersToColumns({
    required List<TableColumn> columns,
    required List<StackedHeader> headers,
  }) {
    stackedHeaders = List.generate(columns.length, (index) {
      return headers.firstWhere(
        (header) => index >= header.startIndex && index <= header.endIndex,
        orElse: () => StackedHeader(width: columns[index].width),
      );
    });
    stackedHeaders = _removeStackedHeaderDuplicates(stackedHeaders);
  }

  void _mapStackedMainHeadersToColumns({
    required List<TableColumn> columns,
    required List<StackedHeader> headers,
  }) {
    stackedMainHeaders = List.generate(columns.length, (index) {
      return headers.firstWhere(
        (header) => index >= header.startIndex && index <= header.endIndex,
        orElse: () => StackedHeader(width: columns[index].width),
      );
    });
    stackedMainHeaders = _removeStackedHeaderDuplicates(stackedMainHeaders);
  }

  /// Determines whether pagination controls should be displayed.
  ///
  /// This function checks multiple conditions to decide if pagination
  /// should be shown:
  /// - Pagination must be enabled (`showPagination` is true).
  /// - The filtered rows list must not be empty.
  /// - `rowsPerPage` must be provided.
  /// - The number of filtered rows must exceed the number of rows per page.
  ///
  /// Parameters:
  /// - [showPagination]: Whether pagination is enabled.
  /// - [filteredRows]: The list of rows after filtering.
  /// - [rowsPerPage]: The number of rows to show per page.
  /// - [/defaultRowsPerPage]: Fallback value if `rowsPerPage` is null (default
  /// is 10).
  ///
  /// Returns:
  /// - `true` if pagination should be shown, otherwise `false`.
  bool shouldShowPagination({
    required bool showPagination,
    required List<dynamic> filteredRows,
    int? rowsPerPage,
  }) {
    if (!showPagination || filteredRows.isEmpty || rowsPerPage == null) {
      return false;
    }

    return filteredRows.length > rowsPerPage;
  }

  /// Returns a [TableColumnWidth] based on layout and column configuration.
  ///
  /// This function determines the appropriate column width for a table cell
  /// depending on the device type and column properties:
  /// - On mobile, a fixed width using [mobileViewWidth] is applied.
  /// - If [columnForcedWidth] is provided, it takes precedence.
  /// - If [/autoFitWidth] is enabled and there are no stacked headers,
  ///   no fixed width is applied (returns `null`).
  /// - If [/columnWidth] is provided, it is used.
  /// - If [/columnSpacing] is provided, it is used.
  /// - Otherwise, returns `null`.
  ///
  /// Parameters:
  /// - [/isMobile]: Whether the layout is for a mobile device.
  /// - [mobileViewWidth]: Fixed width to use for mobile layout.
  /// - [hasStackedHeaders]: Whether the table has stacked headers.
  /// - [/autoFitWidth]: Whether columns should auto-fit their width.
  /// - [columnForcedWidth]: Explicitly forced column width.
  /// - [columnWidth]: Custom column width.
  /// - [/columnSpacing]: Spacing between columns.
  ///an
  /// Returns:
  /// - A [FixedColumnWidth] if applicable, otherwise `null`.
  TableColumnWidth? getColumnWidth({
    required bool hasStackedHeaders,
    required double? columnForcedWidth,
    required double? columnWidth,
  }) {
    if (context.isMobile) {
      return FixedColumnWidth(mobileViewWidth);
    } else if (columnForcedWidth != null) {
      return FixedColumnWidth(columnForcedWidth);
    } else if (!hasStackedHeaders && widget.autoFitWidth) {
      return null;
    } else if (columnWidth != null) {
      return FixedColumnWidth(columnWidth);
    } else if (widget.columnSpacing != null) {
      return FixedColumnWidth(widget.columnSpacing!);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages =
        (_filteredRows.length / (widget.rowsPerPage ?? defaultRowPerPage))
            .ceil();
    final int adjustedTotalPages = totalPages == 0 ? 1 : totalPages;
    final int adjustedCurrentPage =
        _currentPage.clamp(0, adjustedTotalPages - 1);

    int startIndex =
        adjustedCurrentPage * (widget.rowsPerPage ?? defaultRowPerPage);
    int endIndex = (startIndex + (widget.rowsPerPage ?? defaultRowPerPage))
        .clamp(0, _filteredRows.length);
    final List<RowData> visibleRows = widget.rowsPerPage != null
        ? _filteredRows.sublist(
            startIndex,
            endIndex > _filteredRows.length ? _filteredRows.length : endIndex,
          )
        : _filteredRows;

    if (widget.showPagination && widget.isFilterTable) {
      if (startIndex > 0) {
        startIndex -= adjustedCurrentPage;
        endIndex -= adjustedCurrentPage + 1;
      }

      if (startIndex == 0) {
        endIndex -= 1;
      }
    }

    final bool isMobile = context.isMobile;

    final bool hasStackedHeaders = widget.stackedHeaders?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.showCurrencyValue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "common.currencyValue".tr(),
                style: AppStyle.boldLabel,
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor:
                  WidgetStateProperty.all(AppColors.goldenYellow), // dark thumb

              trackColor: WidgetStateProperty.all(
                AppColors.goldenYellow.withValues(alpha: 0.15),
              ),
              trackBorderColor: WidgetStateProperty.all(
                AppColors.goldenYellow.withValues(alpha: 0.35),
              ),
              thickness: WidgetStateProperty.all(8), // thickness in px
              radius: const Radius.circular(6), // rounded corners
              thumbVisibility: WidgetStateProperty.all(true), // default visible
              trackVisibility: WidgetStateProperty.all(true),
            ),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              // isMobile ? true : widget.stackedHeaders?.isNotEmpty ?? false,
              trackVisibility:
                  isMobile || (widget.stackedHeaders?.isNotEmpty ?? false),
              interactive: true,
              child: Listener(
                onPointerSignal: _handleHorizontalPointerSignal,
                child: LayoutBuilder(
                  builder: (context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: (widget.stackedHeaders?.isNotEmpty ?? false)
                              ? Border.all(
                                  color: AppColors.tableActivatedColor,
                                )
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.topStackedHeaders?.isNotEmpty ?? false)
                              DefaultTextStyle.merge(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: widget.headerFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                                child: Row(
                                  children: List.generate(
                                    stackedMainHeaders.length,
                                    (int index) {
                                      final bool isStackedHeader =
                                          stackedMainHeaders[index]
                                                  .startIndex !=
                                              -1;
                                      const Color bordorColor =
                                          AppColors.tableActivatedColor;
                                      return Container(
                                        width: isMobile
                                            ? mobileViewWidth
                                            : stackedMainHeaders[index].width,
                                        height: isMobile
                                            ? mobileViewHeight
                                            : widget.topStackedHeaderHeight ??
                                                30.w,
                                        decoration: BoxDecoration(
                                          color: widget.headerColor ??
                                              AppColors.tableHeadingColor,
                                          border: Border.symmetric(
                                            vertical: const BorderSide(
                                              color: bordorColor,
                                              width: 0.5,
                                            ),
                                            horizontal: !isStackedHeader
                                                ? BorderSide.none
                                                : const BorderSide(
                                                    color: bordorColor,
                                                  ),
                                          ),
                                        ),
                                        child: Center(
                                          child:
                                              stackedMainHeaders[index].widget,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (widget.stackedHeaders?.isNotEmpty ?? false)
                              DefaultTextStyle.merge(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: widget.headerFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                                child: Row(
                                  children: List.generate(
                                    stackedHeaders.length,
                                    (int index) {
                                      final bool isStackedHeader =
                                          stackedHeaders[index].startIndex !=
                                              -1;
                                      const Color bordorColor =
                                          AppColors.tableActivatedColor;
                                      return Container(
                                        width: isMobile
                                            ? mobileViewWidth
                                            : stackedHeaders[index].width,
                                        height: isMobile
                                            ? mobileViewHeight
                                            : widget.stackedHeaderHeight ??
                                                30.w,
                                        decoration: BoxDecoration(
                                          color: widget.headerColor ??
                                              AppColors.tableHeadingColor,
                                          border: Border.symmetric(
                                            vertical: const BorderSide(
                                              color: bordorColor,
                                              width: 0.5,
                                            ),
                                            horizontal: !isStackedHeader
                                                ? BorderSide.none
                                                : const BorderSide(
                                                    color: bordorColor,
                                                  ),
                                          ),
                                        ),
                                        child: Center(
                                          child: stackedHeaders[index].widget,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            tableColumnWidget(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: DataTable(
                                columnSpacing: 0,
                                headingRowHeight:
                                    widget.columnHeaderHeight ?? 40,
                                horizontalMargin: 0,
                                border: (widget.stackedHeaders?.isEmpty ?? true)
                                    ? TableBorder.all(
                                        color: AppColors.tableActivatedColor,
                                      )
                                    : const TableBorder.symmetric(
                                        inside: BorderSide(
                                          color: AppColors.tableActivatedColor,
                                        ),
                                      ),
                                dataRowMinHeight: widget.rowMinHeight ?? 20,
                                dataRowMaxHeight: widget.rowHeight,
                                headingRowColor: WidgetStatePropertyAll(
                                  widget.headerColor ??
                                      AppColors.tableHeadingColor,
                                ),
                                columns: [
                                  ...widget.columns
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final TableColumn column = entry.value;
                                    return TableColumn(
                                      headingRowAlignment:
                                          MainAxisAlignment.center,
                                      label: DefaultTextStyle.merge(
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: widget.headerFontSize,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        child: Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  hasStackedHeaders
                                                      ? (column.isStacked
                                                          ? MainAxisAlignment
                                                              .center
                                                          : MainAxisAlignment
                                                              .start)
                                                      : MainAxisAlignment
                                                          .center,
                                              children: [column.label],
                                            ),
                                          ),
                                        ),
                                      ),
                                      columnWidth: getColumnWidth(
                                        hasStackedHeaders: hasStackedHeaders,
                                        columnForcedWidth: column.forcedWidth,
                                        columnWidth: column.width,
                                      ),
                                      tooltip: column.tooltip,
                                    );
                                  }),
                                ],
                                rows: _filteredRows.isEmpty
                                    ? []
                                    : visibleRows.asMap().entries.map((entry) {
                                        final int displayIndex = entry.key;
                                        final int actualIndex =
                                            startIndex + displayIndex;
                                        final RowData row = entry.value;
                                        return DataRow(
                                          selected:
                                              _selectionStates[actualIndex] ??
                                                  false,
                                          color: WidgetStatePropertyAll(
                                            row.rowColor,
                                          ),
                                          cells: [
                                            ...row.cells
                                                .asMap()
                                                .entries
                                                .map((cellEntry) {
                                              final cellIndex = cellEntry.key;
                                              final cell = cellEntry.value;
                                              return DataCell(
                                                _cellWidget(
                                                  cell,
                                                  _rowData.indexWhere(
                                                    (r) => r.id == row.id,
                                                  ),
                                                  cellIndex,
                                                ),
                                              );
                                            }),
                                          ],
                                        );
                                      }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        // if (widget.showPagination &&
        //     _filteredRows.isNotEmpty &&
        //     widget.rowsPerPage != null)
        //   if (widget.showPagination &&
        //       !(_filteredRows.length <=
        //           (widget.rowsPerPage ?? defaultRowPerPage)))
        Visibility(
          visible: shouldShowPagination(
            showPagination: widget.showPagination,
            filteredRows: _filteredRows,
            rowsPerPage: widget.rowsPerPage,
          ),
          child: Column(
            children: [
              const Gap(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TablePagination(
                    currentPage: adjustedCurrentPage,
                    totalPages: adjustedTotalPages,
                    onPageChanged: _goToPage,
                  ),
                  const Gap(direction: Axis.horizontal),
                  Semantics(
                    label:
                        "Showing records ${startIndex + 1} to ${endIndex.clamp(0, totalCountWOFilter.length)} of ${totalCountWOFilter.length}",
                    child: Text(
                      "Showing ${startIndex + 1}-"
                      "${endIndex.clamp(0, totalCountWOFilter.length)}"
                      " of ${totalCountWOFilter.length}",
                      style: const TextStyle(fontSize: AppStyle.fontSizeSmall),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
