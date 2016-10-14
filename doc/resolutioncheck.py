print("   GSD for 100m x 100m plane   ")
print("-------------------------------")
print("     Pixels    |   GSD (cm)    ")
print("-------------------------------")
pix = (512, 1024, 2048, 4096, 8192, 10000, 15000, 20000, 21600, 25000, 30000, 40000, 50000)
for npix in pix:
    strGSD = "%5.4f" % (100/npix*100)
    print(repr(npix).rjust(6) + " x " + repr(npix).ljust(6) + " | " + strGSD.rjust(10))
