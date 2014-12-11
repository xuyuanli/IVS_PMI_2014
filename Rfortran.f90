!--------------------------------------------------------------------------------------------
!  Rfortran Library License Information  
!
!  (c) Copyright 2006-2010. Mark Thyer, Michael Leonard. All rights reserved.
!
!  This file is part of the RFortran library.
!
!  The RFortran library is free software: you can redistribute it and/or modify
!  it under the terms of the lesser GNU General Public License as published by
!  the Free Software Foundation, either version 3 of the License, or
!  (at your option) any later version.
!
!  The Rfortran library is distributed WITHOUT ANY WARRANTY; 
!  without even the implied warranty of MERCHANTABILITY or FITNESS FOR 
!  A PARTICULAR PURPOSE.  See the lesser GNU General Public License 
!  for more details.
!
!   You should have received a copy of the lesser GNU General Public License
!   along with the Rfortran library.  If not, see <http://www.gnu.org/licenses/>.
!
!--------------------------------------------------------------------------------------------
!  Rfortran Library General Information 
!	
!  For How to Use, FAQ, Bug Reporting/Feature Requests, latest updates, etc. refer to:
!  
!  http://www.rfortran.org
!		
!---------------------------------------------------------------------------------------------
module Rfortran
  !! Rfortran Library Master Module
  !!
  !! Description:
  !! Master module for all Rfortran functionality
   
    ! Core Functionality
    use RFortran_GlobalVars
    use Rfortran_Rput_Rget
    use Rfortran_Rinit_Rclose
    use Rfortran_RgraphicsDevice
    use RFortran_Files
    
    ! Extended Functionality
    use Rfortran_Rfuncs
    use Rfortran_Robjects
    use Rfortran_Rplots
    
    ! Auxillary Functionality
    use MutilsLib_MessageLog
    use MutilsLib_Stringfuncs, only : cl
    
    
end module Rfortran
