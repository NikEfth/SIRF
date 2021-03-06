classdef NiftiImageData3DDeformation < sirf.Reg.NiftiImageData3DTensor & sirf.Reg.Transformation
% Class for deformation image data.

% CCP PETMR Synergistic Image Reconstruction Framework (SIRF).
% Copyright 2018-2019 University College London
% 
% This is software developed for the Collaborative Computational
% Project in Positron Emission Tomography and Magnetic Resonance imaging
% (http://www.ccppetmr.ac.uk/).
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% http://www.apache.org/licenses/LICENSE-2.0
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

    methods(Static)
        function name = class_name()
            name = 'NiftiImageData3DDeformation';
        end
        function obj = same_object()
            obj = sirf.Reg.NiftiImageData3DDeformation();
        end
    end
    methods
        function self = NiftiImageData3DDeformation(src1, src2, src3)
            narginchk(0,3)
            self.name = 'NiftiImageData3DDeformation';
            if nargin < 1
                self.handle_ = calllib('mreg', 'mReg_newObject', self.name);
            elseif ischar(src1)
                self.handle_ = calllib('mreg', 'mReg_objectFromFile', self.name, src1);
            elseif nargin == 3 && isa(src1, 'sirf.SIRF.ImageData') && isa(src2, 'sirf.SIRF.ImageData') && isa(src3, 'sirf.SIRF.ImageData')
                self.handle_ = calllib('mreg', 'mReg_NiftiImageData3DTensor_construct_from_3_components', self.name, src1.handle_, src2.handle_, src3.handle_);                
            elseif isa(src1, 'sirf.Reg.NiftiImageData3DDisplacement')
                self.handle_ = calllib('mreg', 'mReg_NiftiImageData3DDeformation_create_from_disp', src1.handle_);
            end
            sirf.Utilities.check_status(self.name, self.handle_)
        end
        function delete(self)
            if ~isempty(self.handle_)
                sirf.Utilities.delete(self.handle_)
                self.handle_ = [];
            end
        end
    end
    methods(Static)
        function z = compose_single_deformation(trans, ref)
	    	%Compose up to transformations into single deformation.
		    assert(isa(ref, 'sirf.SIRF.ImageData'))
		    assert(isa(trans, 'sirf.Reg.Transformation'))
            num_trans = length(trans);
		    if num_trans == 1
		    	z = trans(1).get_as_deformation_field(ref);
		        return
            end
            % This is ugly. Store each type in a single string (need to do this because I can't get
            % virtual methods to work for multiple inheritance (deformation/displacement are both
            % nifti images and transformations).
            types = '';
            for n = 1:num_trans
                if isa(trans(n),'sirf.Reg.AffineTransformation')
                    types = [types '1'];
                elseif isa(trans(n),'sirf.Reg.NiftiImageData3DDisplacement')
                    types = [types '2'];
                elseif isa(trans(n),'sirf.Reg.NiftiImageData3DDeformation')
                    types = [types '3'];
                end
            end
            % Convert transformations into SIRF vector
            vec = sirf.SIRF.DataHandleVector()
            for n = 1:num_trans
                vec.push_back(trans(n).handle_);
            end
            z = sirf.Reg.NiftiImageData3DDeformation();
            z.handle_ = calllib('mreg', 'mReg_NiftiImageData3DDeformation_compose_single_deformation',ref.handle_, types, vec.handle_);
		end
    end
end