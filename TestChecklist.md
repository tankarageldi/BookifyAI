#  <#Title#>

## Feature Testing Checklist

### Photo Selection
- [ ] Can select photo from library
- [ ] Photo displays correctly
- [ ] Can select different photos (replaces old one)
- [ ] Loading indicator appears during OCR

### OCR Accuracy
- [ ] Detects text from clear images
- [ ] Detects text from book pages
- [ ] Detects text from screenshots
- [ ] Handles rotated images
- [ ] Handles small text
- [ ] Handles different fonts

### Interactive Selection
- [ ] Blue boxes appear around each word
- [ ] Boxes are positioned correctly on words
- [ ] Can tap individual words to select
- [ ] Selected words turn yellow
- [ ] Can tap again to deselect
- [ ] "Select All" selects everything
- [ ] "Clear All" deselects everything
- [ ] Selection counter updates correctly

### Text Display
- [ ] Selected text shows at bottom
- [ ] Text is in correct order (left to right, top to bottom)
- [ ] Multiple words separated by spaces
- [ ] Preview scrolls if too much text

### Edge Cases
- [ ] Image with no text (should handle gracefully)
- [ ] Very small image
- [ ] Very large image
- [ ] Image with lots of text (100+ words)
- [ ] Selecting then clearing then selecting again
- [ ] Switching photos after selection
