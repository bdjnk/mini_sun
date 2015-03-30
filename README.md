Module for Minetest. Adds illuminating cube with a greater light range than normally possible. Currently crafting recipe:

```
copper_ingot  glass         copper_ingot
glass         mese_crystal  glass
copper_ingot  glass         copper_ingot
```

Technically speaking, when a mini sun is placed, it then fills air nodes against non 'airlike' surfaces in a 6x6x6 area with a 3d checkerboard pattern of invisible light nodes of max brightness.
