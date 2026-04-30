part of "../table.dart";

class TablePagination extends StatelessWidget {
  const TablePagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    super.key,
  });
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: "semantics.table.firstPage".tr(),
          child: IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
          ),
        ),
        Semantics(
          label: "semantics.table.previousPage".tr(),
          child: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Page ${currentPage + 1} of $totalPages",
            style: const TextStyle(fontSize: AppStyle.fontSizeSmall),
          ),
        ),
        Semantics(
          label: "semantics.table.nextPage".tr(),
          child: IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages - 1
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),
        ),
        Semantics(
          label: "semantics.table.lastPage".tr(),
          child: IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages - 1
                ? () => onPageChanged(totalPages - 1)
                : null,
          ),
        ),
      ],
    );
  }
}
