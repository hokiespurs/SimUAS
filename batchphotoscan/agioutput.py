import sys
import PhotoScan
import os

if len(sys.argv)==1:
    argv = 'C:\\Users\\slocumr.ONID\\github\\SimUAS\\batchphotoscan\\example.xml'
    projname = argv
    print('agioutput.py projname');
else:
    projname = sys.argv[1]
    print('agioutput.py')

PhotoScan.app.document.open(projname)

saverootname, name = os.path.split(projname)

# Photoscan Convenience Variables
doc = PhotoScan.app.document
app = PhotoScan.Application()
chunk = doc.chunk;

# Save Sparse
sparsesavename = saverootname + "\\sparse.las"
chunk.exportPoints(sparsesavename,PhotoScan.DataSource.PointCloudData.PointCloudData,projection=doc.chunk.crs)

# Save Dense
densesavename = saverootname + "\\dense.las"
chunk.exportPoints(densesavename,PhotoScan.DataSource.PointCloudData.DenseCloudData,projection=doc.chunk.crs)

# Export Report
reportsavename = saverootname + "\\report.pdf"
chunk.exportReport(reportsavename,"agioutput:" + name,\
    "Data was output automatically from the project using agioutput.py")

# Export Camera Calibration File
calibrationsavename = saverootname + "\\sensorcalib.xml"
camCal = chunk.sensors[0]
camCal.calibration.save(calibrationsavename)

# Export GCP File
gcpname = saverootname + "\\markers.txt"
chunk.saveReference(gcpname,format=PhotoScan.ReferenceFormatCSV,items=PhotoScan.ReferenceItems.ReferenceItemsMarkers,columns='noxyzUVWXYZ',delimiter=',')

# Export Trajectory (Cameras)
trajectorysavename = saverootname + "\\trajectory.txt"
chunk.exportCameras(trajectorysavename,projection=doc.chunk.crs,format=PhotoScan.CamerasFormatOPK)
