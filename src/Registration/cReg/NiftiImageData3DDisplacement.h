/*
CCP PETMR Synergistic Image Reconstruction Framework (SIRF)
Copyright 2015 - 2017 Rutherford Appleton Laboratory STFC

This is software developed for the Collaborative Computational
Project in Positron Emission Tomography and Magnetic Resonance imaging
(http://www.ccppetmr.ac.uk/).

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/

/*!
\file
\ingroup Registration
\brief Class for deformation/displacement SIRF image data.

\author Richard Brown
\author CCP PETMR
*/

#ifndef _NIFTIIMAGEDATA3DDISPLACEMENT_H_
#define _NIFTIIMAGEDATA3DDISPLACEMENT_H_

#include "NiftiImageData3DTensor.h"
#include "NiftiImageData3DDeformation.h"
#include <_reg_maths.h>
#include "SIRFRegTransformation.h"

namespace sirf {
template<class dataType> class NiftiImageData3D;

/// SIRF nifti image data displacement field image
template<class dataType>
class NiftiImageData3DDisplacement : public NiftiImageData3DTensor<dataType>, public SIRFRegTransformation<dataType>
{
public:
    /// Constructor
    NiftiImageData3DDisplacement() {}

    /// Filename constructor
    NiftiImageData3DDisplacement(const std::string &filename)
        : NiftiImageData3DTensor<dataType>(filename) { this->check_dimensions(this->_3DDisp); }

    /// Nifti constructor
    NiftiImageData3DDisplacement(const nifti_image &image_nifti)
        : NiftiImageData3DTensor<dataType>(image_nifti) { this->check_dimensions(this->_3DDisp); }

    /// Nifti std::shared_ptr constructor
    NiftiImageData3DDisplacement(const std::shared_ptr<nifti_image> image_nifti)
        : NiftiImageData3DTensor<dataType>(image_nifti) { this->check_dimensions(this->_3DDisp); }

    /// Construct from general tensor
    NiftiImageData3DDisplacement(const NiftiImageData<dataType>& tensor)
        : NiftiImageData3DTensor<dataType>(tensor) { this->check_dimensions(this->_3DDisp); }

    /// Create from 3 individual components
    NiftiImageData3DDisplacement(const NiftiImageData3D<dataType> &x, const NiftiImageData3D<dataType> &y, const NiftiImageData3D<dataType> &z)
        : NiftiImageData3DTensor<dataType>(x,y,z) { this->_nifti_image->intent_p1 = 1; }

    /// Create from deformation field image
    void create_from_def(const NiftiImageData3DDeformation<dataType> &im);

    /// Create from 3D image
    void create_from_3D_image(const NiftiImageData3D<dataType> &image);

    /// Get as deformation field
    virtual NiftiImageData3DDeformation<dataType> get_as_deformation_field(const NiftiImageData3D<dataType> &ref) const;

    /// Get clone sptr
    virtual std::shared_ptr<SIRFRegTransformation<dataType> > get_clone_sptr() const;
};
}

#endif
