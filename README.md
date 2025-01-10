# Mitochondrial-branch-and-thickness
![image](https://github.com/user-attachments/assets/0a283e8a-4c0d-4386-8842-53c75f679c4a)

I.	Introduction

The purpose of this Fiji macro is analyzing the mitochondrial complexity in C. elegans. Comparing to the previous case study in Drosophila [1], the 3D thickness is also included in this analysis. We employed plugins of Local Thickness [2,3], BoneJ [4] in conjunction with 3D object counter to construct this workflow. In the autosaved excel file, you will get measurements of the volume, intensity, local thickness, as well as the size of the bounding box. The analyzed result can be inspected with any 3D modeling software packages such as Imaris. 

  #Examples
  The confocal image of mitochondria in C.elegans (green channel).

  #Description 
  Fiji
   1.	Open the image with bioformat importer. 
   2.	The local background is defined by applying a Gaussian blurring operation with a large sigma value and been subtracted from the raw image. 
   3.	Subsequently, the threshold was adjusted first automatically by default and allowed to be finetuned to generate a mitochondrial mask.
   4.	The thickness, branch complexity and basic 3D geometric measurements of mitochondria is analyzed by Local Thickness plugin, BoneJ plugin and 3D Object Counter respectively.
   5.	In addition to measurements, the analyzed image named “demo image_Results” was saved as well for data inspection. 
  Imaris
   1.	Open the Results folder in the Arena interface.
   2.	Convert the file type of analyzed image from .tiff to .ims by double-clicking on the image. 
   3.	Three additional channels were created in the raw image dataset—mito mask, tagged mitochondrial skeleton and local thickness. The index of each mitochondrion is included in the mito mask channel which was 
      generated by the finetuned threshold for further analysis of thickness and complexity. The branch center and the terminal of mitochondrial skeleton was tagged by different gray values in the additional 
      channel while the 3D local thickness of each mitochondrion was stored as the gray value as well in the other generated channel.
   4.	 Here is the setting of the look up table for easier inspection.
               Channel no	    Name	            Look Up Table (LUT)
               Channel 1	    Mito mask	        Red
               Channel 2	    Raw image	        Gray or green
               Channel 6	    Tagged skeleton	    Fire
               Channel 7	    Local thickness	    Fire
     	 <table>
  <tr>
    <td> Channel no</td>
    <td>Name</td>
    <td>Look Up Table (LUT)</td>
  </tr>
  <tr>
    <td>Channel 1</td>
    <td>Mito mask</td>
    <td>Red</td>
  </tr>
  <tr>
    <td>Channel 2</td>
    <td>Raw image</td>
    <td>Gray or green</td>
  </tr>
   <tr>
    <td>Channel 6</td>
    <td>Tagged skeleton</td>
    <td>Fire</td>
  </tr>
  </tr>
   <tr>
    <td>Channel 7</td>
    <td>Local thickness</td>
    <td>Fire</td>
  </tr>
</table>
   6.	Generate 3D model from the analyzed image. 

II.	Instruction 
1.	Install Fiji is just ImageJ and Imaris. Fiji Download
2.	Download the IJM script and demo image. 
3.	Open the Fiji software.
4.	Make sure you have the BoneJ plugin installed. If not, please install it. BoneJ Installed
5.	Drag and drop the image and IJM script to Fiji, and then execute it.
6.	Finetune the threshold value according to the hint.
7.	The final results are saved to an Excel file for further statistics.
8.	Open the analyzed image in Imaris for 3D modeling. 

III.	Published with
(Submitting information about publication or project).
IV.	Acknowledgements
V.	Reference
1.	Shao-Chun, Peggy, Hsu, & szutinglin. (2024). peggyscshu/Fruit-fly-mitochondrial-morphology-assay: v1.0.0 (v1.0.0). Zenodo. https://doi.org/10.5281/zenodo.14435377
2.	"A new method for the model-independent assessment of thickness in three-dimensional images" T. Hildebrand and P. Rüesgsegger, J. of Microscopy, 185 (1996) 67-75.
3.	"New algorithms for Euclidean distance transformation on an n-dimensional digitized picture with applications," T. Saito and J. Toriwaki, Pattern Recognition 27 (1994) 1551-1565.
4.	Domander, R., Felder, A. A., & Doube, M. (2021). BoneJ2 - refactoring established research software. Wellcome Open Research, 6, 37. doi:10.12688/wellcomeopenres.16619.2

