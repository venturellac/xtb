! This file is part of xtb.
!
! Copyright (C) 2019-2020 Sebastian Ehlert
!
! xtb is free software: you can redistribute it and/or modify it under
! the terms of the GNU Lesser General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! xtb is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU Lesser General Public License for more details.
!
! You should have received a copy of the GNU Lesser General Public License
! along with xtb.  If not, see <https://www.gnu.org/licenses/>.

!> Supported file types in this program
module xtb_mctc_filetypes
   use xtb_mctc_accuracy, only : wp
   use xtb_mctc_chartools, only : toLowercase
   implicit none
   private

   public :: fileType, getFileType, generateFileMetaInfo


   !> Possible file types
   type :: TFileTypeEnum

      !> xyz-format
      integer :: xyz = 1

      !> Turbomole coordinate format
      integer :: tmol = 2

      !> mol-format
      integer :: molfile = 3

      !> Vasp coordinate input
      integer :: vasp = 4

      !> Protein database format
      integer :: pdb = 5

      !> Structure data format
      integer :: sdf = 6

      !> GenFormat of DFTB+
      integer :: gen = 7

      !> Gaussian external format
      integer :: gaussian = 8

   end type TFileTypeEnum

   !> File type enumerator
   type(TFileTypeEnum), parameter :: fileType = TFileTypeEnum()

   !> Default file type
   integer, parameter :: defaultFileType = fileType%tmol


contains


!> Generate file type from file name
function getFileType(name) result(ftype)

   !> File name
   character(len=*), intent(in) :: name

   !> File type
   integer :: ftype

   character(len=:), allocatable :: basename, extension, path

   call generateFileMetaInfo(name, path, basename, extension)

   ftype = defaultfileType

   if (len(basename) > 0) then
      select case(toLowercase(basename))
      case('coord')
         ftype = fileType%tmol
      case('poscar', 'contcar')
         ftype = fileType%vasp
      end select
   endif

   if (len(extension) > 0) then
      select case(toLowercase(extension))
      case('coord', 'tmol')
         ftype = fileType%tmol
      case('xyz')
         ftype = fileType%xyz
      case('mol')
         ftype = fileType%molfile
      case('sdf')
         ftype = fileType%sdf
      case('poscar', 'contcar', 'vasp')
         ftype = fileType%vasp
      case('pdb')
         ftype = fileType%pdb
      case('gen')
         ftype = fileType%gen
      case('ein')
         ftype = fileType%gaussian
      end select
   end if

end function getFileType


!> Split file name into path, basename and extension
subroutine generateFileMetaInfo(Name, path, basename, extension)

   !> File name
   character(len=*), intent(in) :: name

   !> Path to the file, empty if no path found in name
   character(len=:), allocatable, intent(out) :: path

   !> Base name of the file
   character(len=:), allocatable, intent(out) :: basename

   !> Extension of the file name, empty if no extension present
   character(len=:), allocatable, intent(out) :: extension

   integer :: iDot, iSlash

   iDot = index(name, '.', back=.true.)
   iSlash = index(name, '/', back=.true.)

   if (iDot > iSlash .and. iDot > 0) then
      extension = name(iDot+1:)
   else ! means point is somewhere in the path or absent
      iDot = len(name)+1
      extension = ''
   endif

   if (iDot > iSlash .and. iSlash > 0) then
      basename = name(iSlash+1:iDot-1)
   else
      basename = ''
   endif

   if (iSlash > 0) then
      path = name(:iSlash)
   else
      path = ''
   endif

end subroutine generateFileMetaInfo


end module xtb_mctc_filetypes
