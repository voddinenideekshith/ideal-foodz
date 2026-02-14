# Ideal Foodz Menu Image Validation Report

Date: 2026-02-14
Scope: Full menu section image-to-item mapping using only files currently present in `images/`.

## Summary

- Total menu items audited: 23
- Local image references in menu: 22
- Broken image links: 0
- Strategy used: strict local-file mapping from `images/` with normalized filenames

## Validation Table

| Item Name | Image Generated | Verification Status |
|---|---|---|
| Paneer Butter Masala | images/paneer_butter_masala.png | Matched |
| Chicken Butter Masala | images/chicken_butter_masala.png | Matched |
| Paneer Masala | images/paneer_masala.png | Corrected |
| Kadai Chicken | images/kadai_chicken.jpg | Matched |
| Chicken Curry | images/chicken_curry.jpg | Matched |
| Chicken Soup | images/chicken_soup.jpg | Matched |
| Chicken Roast Fry | images/chicken_roast_fry.jpg | Matched |
| Veg Manchurian | images/veg_manchurian.jpg | Matched |
| Chicken 65 | images/chicken_65.jpg | Corrected |
| Chicken Biryani | images/chicken_biryani.jpg | Matched |
| Veg Biryani | images/veg_biryani.jpg | Matched |
| Paneer Biryani | images/paneer_biryani.jpg | Matched |
| Bagara Rice | images/bagara_rice.jpg | Matched |
| Jeera Rice | images/jeera_rice.jpg | Matched |
| Curd Rice | images/curd_rice.jpg | Corrected |
| Roti | images/roti.jpg | Corrected |
| Chapathi | images/chapathi.jpg | Matched |
| Plain Naan | images/plain_naan.jpg | Matched |
| Butter Naan | images/butter_naan.jpg | Matched |
| Papad | images/papad.jpg | Matched |
| Raita | images/raita.jpg | Corrected |
| Water Bottle | images/water_bottle.jpg | Matched |

## Notes

- `Corrected` means mapped from the closest available local image file because there was no exact-name original for that menu item.
- Menu layout consistency remains unchanged and all menu images are now loading from local assets.
