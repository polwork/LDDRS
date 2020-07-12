# Full-Time Monocular Road Detection Using Zero-Distribution Prior of Angle of Polarization. ECCV2020

## Database download
This is a LWIR DoFP Dataset of Road Scene (LDDRS) associated with the article.
- baidu(https://pan.baidu.com/s/1-aDyIltuozqSvLpjcisCGQ  Extraction code：1zgs)
- google(https://drive.google.com/file/d/1a3JrDtpkBoEm_sGJJQ1ClSmczdw1KFAC/view?usp=sharing)

- Folders:
	- "RAW" folder : Original LWIR DoFP images of road scene with 512×640 resolution in 14 bits.
	- "label" folder : Corresponding label of road region of 2,113 images. 1 represents road and 0 represents background.
	- "S0" folder : Corresponding intensity image after denoising and HDR correction.
- Code:
	- demo.m : A demo code for basic pre-processing of DoFP image, including denoising, demosaicking and calculating Stokes parameters.
	- BM3D : Denoising the raw DoFP image.
	- FFC_Polynomial_interpolation.m : A demosaicking algorithm [1] for recovering four high resolution polarization image from an input DoFP image.	
	- IRHDRv1.m : HDR correction of the S0 image.
- Note:
	- The polarization transmission direction of each pixel of DoFP image is arranged as in "Pixel arrangement of DoFP image.jpg".

[1] Li, N., Zhao, Y., Pan, Q., Kong, S.G.: Demosaicking DoFP images using Newton's polynomial interpolation and polarization difference model. Optics Express 27(2), 1376–1391 (2019)



If you have any question, please contact ：ln_neo@mail.nwpu.edu.cn


