#!/Library/Frameworks/Python.framework/Versions/Current/bin/python
#make_feat_fsf_7TSept.py

"""
Doc string
""" 

import os
import glob

import numpy as np

def replace_all(text, d):
    for i, j in d.iteritems():
        text = text.replace(i, j)
    return text

def replace_all_in_file(infile, d, outfile):
	f_in = open(infile)
	f_out = open(outfile,'w')
	for line in f_in:
	    f_out.write(replace_all(line, d))
	f_out.close()
	f_in.close()

def main():
	# sample fsf file
	sample_file = "sample_setup.fsf"
	epi_fsf_outdir = "AV"

	# set for each subject
	session_name = "AV_20130922"
	path_to_T1_masked = "/Volumes/Plata1/Anatomies/Anatomicals/AV/AV_nu_brainmasked.nii.gz"

	# set up directories
	session_dir = "/Volumes/Plata1/LGN/Scans/7T/{}_Session".format(session_name)
	scan_dir = "{}/{}".format(session_dir, session_name)
	dicom_dir = "{}/{}_dicom".format(scan_dir, session_name)
	nifti_dir = "{}/{}_nifti".format(scan_dir, session_name)
	fieldmap_dir = "{}/Field_Mapping/field_map_nifti".format(session_dir)

	dir_list = np.array(os.listdir(dicom_dir)) 
	#In order to not include any extra files
	epi_list = []
	for file in dir_list:
	    if file.startswith('epi'):
	        epi_list.append(file)

	# Loop through the epis, creating an fsf file for each run
	for epi in epi_list:
		epi_dicom_dir = "{}/{}".format(dicom_dir, epi)
		n_TRs = len(glob.glob1(epi_dicom_dir,"*.dcm"))

		if epi.endswith('rest') or epi.endswith('ss'):
			slice_time_op = 4 # Use slice timings file
			slice_time_file = "{}/slicetimeshift.txt".format(scan_dir)
		else:
			slice_time_op = 0 # No slice time correction
			slice_time_file = ""

		path_to_epi = "{}/{}.nii.gz".format(nifti_dir, epi)
		path_to_refvol = "{}/refvol.nii".format(nifti_dir)
		path_to_fieldmap = "{}/fieldmap.nii.gz".format(fieldmap_dir)
		path_to_mag1 = "{}/mag1_masked_e.nii.gz".format(fieldmap_dir)

		# Make the dict of strings to replace
		fsf_vars = {}
		fsf_vars['{N-TRS}'] = str(n_TRs)
		fsf_vars['{SLICE-TIME-OP}'] = str(slice_time_op)
		fsf_vars['{SLICE-TIME-FILE}'] = slice_time_file
		fsf_vars['{PATH-TO-EPI}'] = path_to_epi
		fsf_vars['{PATH-TO-REFVOL}'] = path_to_refvol
		fsf_vars['{PATH-TO-FIELDMAP}'] = path_to_fieldmap
		fsf_vars['{PATH-TO-MAG1-MASKED-E}'] = path_to_mag1
		fsf_vars['{PATH-TO-T1-BRAINMASKED}'] = path_to_T1_masked

		epi_fsf_file = "{}/{}.fsf".format(epi_fsf_outdir, epi)
		replace_all_in_file(sample_file, fsf_vars, epi_fsf_file)

if __name__ == "__main__": 
	main()







