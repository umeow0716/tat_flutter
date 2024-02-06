import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class CustomMultiSelectDialog<T> extends MultiSelectDialog<T> {
  CustomMultiSelectDialog({
    required super.items,
    required super.initialValue,
    super.title,
    super.onSelectionChanged,
    super.onConfirm,
    super.listType,
    super.searchable = false,
    super.confirmText,
    super.cancelText,
    super.selectedColor,
    super.searchHint,
    super.height,
    super.width,
    super.colorator,
    super.backgroundColor,
    super.unselectedColor,
    super.searchIcon,
    super.closeSearchIcon,
    super.itemsTextStyle,
    super.searchHintStyle,
    super.searchTextStyle,
    super.selectedItemsTextStyle,
    super.separateSelectedItems = false,
    super.checkColor,
    Key? key,
  });

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<T>(items);
}

class _MultiSelectDialogState<T> extends State<MultiSelectDialog<T>> {
  List<T> _selectedValues = [];
  bool _showSearch = false;
  List<MultiSelectItem<T>> _items;

  _MultiSelectDialogState(this._items);

  @override
  void initState() {
    super.initState();
    _selectedValues.addAll(widget.initialValue);

    for (int i = 0; i < _items.length; i++) {
      _items[i].selected = false;
      if (_selectedValues.contains(_items[i].value)) {
        _items[i].selected = true;
      }
    }

    if (widget.separateSelectedItems) {
      _items = widget.separateSelected(_items);
    }
  }

  /// Returns a CheckboxListTile
  Widget _buildListItem(MultiSelectItem<T> item) {
    return SizedBox(
      height: 62.0,
      child: Theme(
        data: ThemeData(
          unselectedWidgetColor: widget.unselectedColor ?? Colors.black54,
        ),
        child: CheckboxListTile(
          checkColor: widget.checkColor,
          value: item.selected,
          activeColor: widget.colorator != null
              ? widget.colorator!(item.value) ?? widget.selectedColor
              : widget.selectedColor,
          title: Text(
            item.label,
            style: item.selected
                ? widget.selectedItemsTextStyle
                : widget.itemsTextStyle,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (checked) {
            setState(() {
              _selectedValues = widget.onItemCheckedChange(
                  _selectedValues, item.value, checked!);

              if (checked) {
                item.selected = true;
              } else {
                item.selected = false;
              }
              if (widget.separateSelectedItems) {
                _items = widget.separateSelected(_items);
              }
            });
            if (widget.onSelectionChanged != null) {
              widget.onSelectionChanged!(_selectedValues);
            }
          },
        ),
      )
    );
  }

  /// Returns a ChoiceChip
  Widget _buildChipItem(MultiSelectItem<T> item) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: ChoiceChip(
        backgroundColor: widget.unselectedColor,
        selectedColor: widget.colorator?.call(item.value) ??
            widget.selectedColor ??
            Theme.of(context).primaryColor.withOpacity(0.35),
        label: Text(
          item.label,
          style: item.selected
              ? TextStyle(
                  color: widget.selectedItemsTextStyle?.color ??
                      widget.colorator?.call(item.value) ??
                      widget.selectedColor?.withOpacity(1) ??
                      Theme.of(context).primaryColor,
                  fontSize: widget.selectedItemsTextStyle?.fontSize,
                )
              : widget.itemsTextStyle,
        ),
        selected: item.selected,
        onSelected: (checked) {
          if (checked) {
            item.selected = true;
          } else {
            item.selected = false;
          }
          setState(() {
            _selectedValues = widget.onItemCheckedChange(
                _selectedValues, item.value, checked);
          });
          if (widget.onSelectionChanged != null) {
            widget.onSelectionChanged!(_selectedValues);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.backgroundColor,
      title: widget.searchable == false
          ? widget.title ?? const Text("Select")
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _showSearch
                    ? Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 10),
                          child: TextField(
                            style: widget.searchTextStyle,
                            decoration: InputDecoration(
                              hintStyle: widget.searchHintStyle,
                              hintText: widget.searchHint ?? "Search",
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: widget.selectedColor ??
                                      Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              List<MultiSelectItem<T>> filteredList = [];
                              filteredList =
                                  widget.updateSearchQuery(val, widget.items);
                              setState(() {
                                if (widget.separateSelectedItems) {
                                  _items =
                                      widget.separateSelected(filteredList);
                                } else {
                                  _items = filteredList;
                                }
                              });
                            },
                          ),
                        ),
                      )
                    : widget.title ?? const Text("Select"),
                IconButton(
                  icon: _showSearch
                      ? widget.closeSearchIcon ?? const Icon(Icons.close)
                      : widget.searchIcon ?? const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) {
                        if (widget.separateSelectedItems) {
                          _items = widget.separateSelected(widget.items);
                        } else {
                          _items = widget.items;
                        }
                      }
                    });
                  },
                ),
              ],
            ),
      contentPadding:
          widget.listType == null || widget.listType == MultiSelectListType.LIST
              ? const EdgeInsets.only(top: 12.0)
              : const EdgeInsets.all(20),
      content: SizedBox(
        height: widget.height,
        width: widget.width ?? MediaQuery.of(context).size.width * 0.73,
        child: widget.listType == null ||
                widget.listType == MultiSelectListType.LIST
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildListItem(_items[index]);
                },
              )
            : SingleChildScrollView(
                child: Wrap(
                  children: _items.map(_buildChipItem).toList(),
                ),
              ),
      ),
      actions: <Widget>[
        TextButton(
          child: widget.cancelText ??
              Text(
                "CANCEL",
                style: TextStyle(
                  color: (widget.selectedColor != null &&
                          widget.selectedColor != Colors.transparent)
                      ? widget.selectedColor!.withOpacity(1)
                      : Theme.of(context).primaryColor,
                ),
              ),
          onPressed: () {
            widget.onCancelTap(context, widget.initialValue);
          },
        ),
        TextButton(
          child: widget.confirmText ??
              Text(
                'OK',
                style: TextStyle(
                  color: (widget.selectedColor != null &&
                          widget.selectedColor != Colors.transparent)
                      ? widget.selectedColor!.withOpacity(1)
                      : Theme.of(context).primaryColor,
                ),
              ),
          onPressed: () {
            widget.onConfirmTap(context, _selectedValues, widget.onConfirm);
          },
        )
      ],
    );
  }
}