# QTAB pre-processing
## MP2RAGE background noise
The amplified background noise in the MP2RAGE uniform image (*UNIT1*) can cause issues with registration and segmentation algorithms. One technique for dealing with this problem is to input brain-extracted (i.e., skull-stripped) MP2RAGE uniform images to automated processing pipelines (e.g. FreeSurfer, fMRIPrep). We found that creating a brain mask based on the second inversion time image (*inv-2_MP2RAGE*) and applying this mask to the MP2RAGE uniform image (*UNIT1*) resulted in successful brain extractions (see anat/inv-2_brain_extraction.sh)

## Unwarping of diffusion and functional scans
Diffusion and rs-fMRI scans were acquired using reversed-phase encoding directions to correct geometric distortions in the images. We recommend using the FSL tools topup and eddy to correct for distortions and movement in the diffusion scans and topup and applytop to correct the rs-fMRI scans. Similarly, we recommend using the reversed-phase encoding field maps and the FSL tools topup and FEAT to correct the t-fMRI scans.
