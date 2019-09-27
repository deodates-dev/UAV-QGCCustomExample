/****************************************************************************
 *
 * (c) 2009-2019 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 * @file
 *   @brief Camera Controller
 *   @author Gus Grubba <gus@auterion.com>
 *
 */

#include "CustomCameraControl.h"
#include "QGCCameraIO.h"

QGC_LOGGING_CATEGORY(CustomCameraLog, "CustomCameraLog")
QGC_LOGGING_CATEGORY(CustomCameraVerboseLog, "CustomCameraVerboseLog")

static const char* kCAM_IRPALETTE            = "CAM_IRPALETTE";
static const char* kCAM_ENC                  = "CAM_ENC";
static const char* kCAM_SENSOR               = "CAM_SENSOR";
static const int   kCAM_SENSOR_VS            = 0;
static const int   kCAM_SENSOR_IR            = 1;

//-----------------------------------------------------------------------------
CustomCameraControl::CustomCameraControl(const mavlink_camera_information_t *info, Vehicle* vehicle, int compID, QObject* parent)
    : QGCCameraControl(info, vehicle, compID, parent)
{
}

//-----------------------------------------------------------------------------
bool
CustomCameraControl::takePhoto()
{
    bool res = false;
    res = QGCCameraControl::takePhoto();
    return res;
}

//-----------------------------------------------------------------------------
bool
CustomCameraControl::stopTakePhoto()
{
    bool res = QGCCameraControl::stopTakePhoto();
    return res;
}

//-----------------------------------------------------------------------------
bool
CustomCameraControl::startVideo()
{
    bool res = QGCCameraControl::startVideo();
    return res;
}

//-----------------------------------------------------------------------------
bool
CustomCameraControl::stopVideo()
{
    bool res = QGCCameraControl::stopVideo();
    return res;
}

//-----------------------------------------------------------------------------
void
CustomCameraControl::setVideoMode()
{
    if(cameraMode() != CAM_MODE_VIDEO) {
        qCDebug(CustomCameraLog) << "setVideoMode()";
        Fact* pFact = getFact(kCAM_MODE);
        if(pFact) {
            pFact->setRawValue(CAM_MODE_VIDEO);
            _setCameraMode(CAM_MODE_VIDEO);
        }
    }
}

//-----------------------------------------------------------------------------
void
CustomCameraControl::setPhotoMode()
{
    if(cameraMode() != CAM_MODE_PHOTO) {
        qCDebug(CustomCameraLog) << "setPhotoMode()";
        Fact* pFact = getFact(kCAM_MODE);
        if(pFact) {
            pFact->setRawValue(CAM_MODE_PHOTO);
            _setCameraMode(CAM_MODE_PHOTO);
        }
    }
}

//-----------------------------------------------------------------------------
void
CustomCameraControl::_setVideoStatus(VideoStatus status)
{
    QGCCameraControl::_setVideoStatus(status);
}

//-----------------------------------------------------------------------------
void
CustomCameraControl::handleCaptureStatus(const mavlink_camera_capture_status_t& cap)
{
    QGCCameraControl::handleCaptureStatus(cap);
}

//-----------------------------------------------------------------------------
Fact*
CustomCameraControl::irPalette()
{
    if(_paramComplete) {
        if(_activeSettings.contains(kCAM_IRPALETTE)) {
            return getFact(kCAM_IRPALETTE);
        }
    }
    return nullptr;
}

//-----------------------------------------------------------------------------
Fact*
CustomCameraControl::videoEncoding()
{
    return _paramComplete ? getFact(kCAM_ENC) : nullptr;
}

//-----------------------------------------------------------------------------
void
CustomCameraControl::setThermalMode(ThermalViewMode mode)
{
    if(_paramComplete) {
        if(_activeSettings.contains(kCAM_SENSOR)) {
            if(mode == THERMAL_FULL) {
                getFact(kCAM_SENSOR)->setRawValue(kCAM_SENSOR_IR);
            }
            else if(mode == THERMAL_OFF) {
                getFact(kCAM_SENSOR)->setRawValue(kCAM_SENSOR_VS);
            }
        }
    }
    QGCCameraControl::setThermalMode(mode);
}
