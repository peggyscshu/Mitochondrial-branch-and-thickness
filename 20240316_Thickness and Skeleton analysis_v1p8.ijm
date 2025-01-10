/*  - Dependency: BoneJ
 *  - Subtracted less background to reserve more detail.
 *  - Measure the local thickness in floating point and volume of mitochondria. 
 *  - Skeletonize mito with BoneJ and analyzed them with regular analyzer.
 *  - Measure raw terminal point no. instead of centroids. 
 *  - Generate composed image with appropriate LUT in 16-bit for inspection. (1 Mito ID 2. Raw 3. Terminal point 4. Branch center 5. Junction center 6. Tagged skeleton)
 *  - Add measurement of branch length, mito mean intensity
 *  - Compiled by Shao-Chun, Peggy, Hsu by 2024/3/16.
 * - peggyschsu@ntu.edu.tw
 * 
 */
 ts=getTime();
//setBatchMode("hide");
//Prepare
  tifName = getTitle();
  Name = replace(tifName, ".lsm", "");
  selectWindow(tifName);
  rename("Raw");
  getDimensions(fsw, fsh, channels, slices, frames);
  getVoxelSize(width, height, depth, unit);
  dir1= getDirectory("image");
  dir2 = dir1 + File.separator + Name+"_Results";
	if (File.exists(dir2)==false) {
				File.makeDirectory(dir2);
	}
  print("Analyzing " + tifName + " ......");
//Get mito mask
	selectWindow("Raw");
	setSlice(5);
	run("Enhance Contrast", "saturated=0.35");
	run("Set... ", "zoom=60 x=512 y=512");
	run("Duplicate...", "title=BG duplicate");
	selectWindow("BG");
	run("Gaussian Blur...", "sigma=15 stack");
	imageCalculator("Subtract create stack", "Raw","BG");
	selectWindow("BG");
	close();
	selectWindow("Result of Raw");
	run("Gaussian Blur...", "sigma=1 stack");
	//run("Apply LUT", "stack");
	run("Threshold...");
	setSlice(5);
	run("Set... ", "zoom=60 x=512 y=512");
	setAutoThreshold("Default dark");
	waitForUser("Adjust the threshold accordingly");//If the threshold can be fixed, this could be muted.
	getThreshold(lower, upper);
	setThreshold(lower, upper);
	run("Convert to Mask", "background=Dark create");
	selectWindow("MASK_Result of Raw");
	rename("MitoMask");
	/*
	//Inspection
		Ipslice = 18;
		selectWindow("MASK_Result of Raw");
		setSlice(Ipslice);
		setThreshold(255, 255, "raw");
		run("Analyze Particles...", "add slice");
		selectWindow("Raw");
		setSlice(Ipslice);
		roiManager("Show All without labels");
	*/	
	//Clear
		selectWindow("Result of Raw");
		close();
//Analyze local thickness
	selectWindow("MitoMask");
	run("Local Thickness (complete process)", "threshold=125");
	selectWindow("MitoMask_LocThk");
	run("Multiply...", "value=100 stack");
	setMinAndMax(0.00, 1077.03);//Used to update the min max function
	getMinAndMax(min, max);
	GVtoPx=65535/max;
	run("16-bit");
	run("Divide...", "value=GVtoPx stack");
	selectWindow("MitoMask_LocThk");
	setMinAndMax(0, 2000);
	run("3D OC Options", "volume nb_of_obj._voxels maximum_gray_value bounding_box dots_size=5 font_size=10 redirect_to=MitoMask_LocThk");
	selectWindow("MitoMask");
	run("16-bit");
	run("3D Objects Counter", "threshold=128 slice=14 min.=10 max.=30408704 objects statistics");
	Ar_Vol_px = Table.getColumn("Nb of obj. voxels");
	voxToum3 = width*height*depth;
	Ar_Vol_um3 = newArray(0);
	for (i = 0; i < lengthOf(Ar_Vol_px); i++) {
		volum3= Ar_Vol_px[i]*voxToum3;
		Ar_Vol_um3 = Array.concat(Ar_Vol_um3,volum3);
	}
	Ar_MaxLocalThickness_100X = Table.getColumn("Max");
	//Array.print(Ar_MaxLocalThickness_100X);
	Ar_MaxLocalThickness = newArray(0);
	for (i = 0; i < lengthOf(Ar_MaxLocalThickness_100X); i++) {
		MLT = Ar_MaxLocalThickness_100X[i]/100;
		Ar_MaxLocalThickness = Array.concat(Ar_MaxLocalThickness,MLT);
	}
	Ar_Ind = newArray(0);
	for (i = 1; i < lengthOf(Ar_MaxLocalThickness)+1; i++) {
		Ar_Ind = Array.concat(Ar_Ind,i);
	}
	Ar_BBoxW = Table.getColumn("B-width");
	Ar_BBoxW_um = newArray(0);
	for (i = 0; i < lengthOf(Ar_BBoxW); i++) {
		BWum= Ar_BBoxW[i]*width;
		Ar_BBoxW_um = Array.concat(Ar_BBoxW_um,BWum);
	}
	Ar_BBoxH = Table.getColumn("B-height");
	Ar_BBoxH_um = newArray(0);
	for (i = 0; i < lengthOf(Ar_BBoxH); i++) {
		BHum= Ar_BBoxH[i]*width;
		Ar_BBoxH_um = Array.concat(Ar_BBoxH_um,BHum);
	}
	Ar_BBoxD = Table.getColumn("B-depth");
	Ar_BBoxD_um = newArray(0);
	for (i = 0; i < lengthOf(Ar_BBoxD); i++) {
		BDum= Ar_BBoxD[i]*depth;
		Ar_BBoxD_um = Array.concat(Ar_BBoxD_um,BDum);
	}
	run("Clear Results");
//Analyze mito intensity
	run("3D OC Options", "mean_gray_value dots_size=5 font_size=10 redirect_to=Raw");
    selectWindow("MitoMask");
	run("3D Objects Counter", "threshold=128 slice=14 min.=10 max.=30408704 objects statistics");
	Ar_MitoInt = Table.getColumn("Mean");
//Create measurement table
	Table.create("Mito measurement table");
	Table.setColumn("Index", Ar_Ind);
	Table.setColumn("Volume(px)", Ar_Vol_px);
	Table.setColumn("Volume(um3)", Ar_Vol_um3);
	Table.setColumn("Bounding box width (um)", Ar_BBoxW_um);
	Table.setColumn("Bounding box height(um)", Ar_BBoxH_um);
	Table.setColumn("Bounding box depth (um)", Ar_BBoxD_um);
	Table.setColumn("Mito mean intensity", Ar_MitoInt);
	Table.setColumn("MaxLocalThickness(um)", Ar_MaxLocalThickness);

	//Save Result of Thickness
		selectWindow("Raw");
		saveAs("Tiff", dir2 + File.separator + Name +"_Raw.tif");
		selectWindow("Objects map of MitoMask redirect to MitoMask_LocThk");
		saveAs("Tiff", dir2 + File.separator + Name +"_Map.tif");
		selectImage("MitoMask_LocThk");
		saveAs("Tiff", dir2+ File.separator + Name +"_Thickness.tif");
		selectImage("MitoMask");
		saveAs("Tiff", dir2 + File.separator + Name +"_MitoMask.tif");
		selectWindow("Mito measurement table");
		saveAs("Results", dir2 + File.separator + Name +"_Result.csv");
	//Clear
		run("Clear Results");
		selectWindow(Name + "_Raw.tif");
		close();
		selectWindow(Name + "_Map.tif");
		close();
		selectWindow(Name + "_Thickness.tif");
		close();
//Analyze skeleton
	selectWindow(Name + "_MitoMask.tif");
	rename("MitoMask");
	//Get mito 3D skeleton	
		run("8-bit");
		run("Skeletonize");//From BoneJ
		run("Analyze Skeleton (2D/3D)", "prune=none display");
	//Get terminal image
		selectWindow("Tagged skeleton");
		setThreshold(25, 31, "raw");
		run("Convert to Mask", "background=Dark black create");
		selectWindow("MASK_Tagged skeleton");
		rename("Terminal");
		run("Divide...", "value=255 stack");
	//Get branch image
		selectWindow("Tagged skeleton");
		setThreshold(125, 128, "raw");
		run("Convert to Mask", "background=Dark black create");
		selectWindow("MASK_Tagged skeleton");
		rename("Branch");
	//Get branch centroid
		selectWindow("Branch");
		run("3D OC Options", "  dots_size=5 font_size=10 redirect_to=none");
		run("3D Objects Counter", "threshold=128 slice=13 min.=0 max.=153468 centres_of_masses");
		setThreshold(1, 65535);
		run("Convert to Mask", "background=Dark create");
		run("Ultimate Points", "stack");
		selectWindow("MASK_Centres of mass map of Branch");
		rename("Branch centroid");
		run("Grays");
		run("Divide...", "value=3 stack");
	//Get Junction centroid
		selectWindow("Tagged skeleton");
		setThreshold(65, 71, "raw");
		run("Convert to Mask", "background=Dark black create");
		selectWindow("MASK_Tagged skeleton");
		rename("Junction");
		run("3D OC Options", "  dots_size=5 font_size=10 redirect_to=none");
		run("3D Objects Counter", "threshold=128 slice=13 min.=0 max.=153468 centres_of_masses");
		setThreshold(1, 65535);
		run("Convert to Mask", "background=Dark create");
		run("Ultimate Points", "stack");
		selectWindow("MASK_Centres of mass map of Junction");
		rename("Junction centroid");
		run("Grays");
		run("Divide...", "value=3 stack");
	//Clear
		selectImage("Skeleton-labeled-skeletons");
		close();
		selectWindow("Junction");
		close();
		selectWindow("Centres of mass map of Junction");
		close();
		selectWindow("Centres of mass map of Branch");
		close();
		run("Clear Results");
	//Measure data
		//Junction no
			selectWindow("Junction centroid");
			run("3D OC Options", "integrated_density dots_size=5 font_size=10 redirect_to=[Junction centroid]");
			selectWindow("MitoMask");
			run("3D Objects Counter", "threshold=255 slice=13 min.=10 max.=30408704 objects statistics summary");
			selectWindow("Results");
			run("Divide...", "value=3 stack");
			Ar_Junction = Table.getColumn("IntDen");
			//Save image
				selectWindow("Junction centroid");
				setMinAndMax(0, 1);
				saveAs("Tiff", dir2 + File.separator + Name +"_Junction center.tif");
			//Clear
				run("Clear Results");
				selectWindow(Name + "_Junction center.tif");
				close();
				selectImage("Objects map of MitoMask redirect to Junction centroid");
				close();
		//Branch no
			selectWindow("Branch centroid");
			run("3D OC Options", "integrated_density dots_size=5 font_size=10 redirect_to=[Branch centroid]");
			selectWindow("MitoMask");
			run("3D Objects Counter", "threshold=255 slice=13 min.=10 max.=30408704 objects statistics summary");
			selectWindow("Results");
			Ar_Branch = Table.getColumn("IntDen");
			//Save image
				selectWindow("Branch centroid");
				setMinAndMax(0, 1);
				saveAs("Tiff", dir2 + File.separator + Name +"_Branch center.tif");
			//Clear
				run("Clear Results");
				selectWindow(Name + "_Branch center.tif");
				close();
				selectImage("Objects map of MitoMask redirect to Branch centroid");
				close();
		//Branch length
			selectWindow("Branch");
			run("Divide...", "value=255 stack");
			run("3D OC Options", "integrated_density dots_size=5 font_size=10 redirect_to=[Branch]");
			selectWindow("MitoMask");
			run("3D Objects Counter", "threshold=255 slice=13 min.=10 max.=30408704 objects statistics summary");
			selectWindow("Results");
			Ar_BranchLpx = Table.getColumn("IntDen");
			Ar_BranchL_um = newArray(0);
			for (i = 0; i < lengthOf(Ar_BranchLpx); i++) {
				BranchLum= Ar_BranchLpx[i]*width;
				Ar_BranchL_um = Array.concat(Ar_BranchL_um,BranchLum);
			}
			//Save image
				selectWindow("Branch");
				setMinAndMax(0, 1);
				saveAs("Tiff", dir2 + File.separator + Name +"_Branch Length.tif");
			//Clear
				run("Clear Results");
				selectWindow(Name + "_Branch Length.tif");
				close();
				selectImage("Objects map of MitoMask redirect to Branch");
				close();
		//Terminal no
			selectWindow("Terminal");
			run("3D OC Options", "integrated_density dots_size=5 font_size=10 redirect_to=[Terminal]");
			selectWindow("MitoMask");
			run("3D Objects Counter", "threshold=255 slice=13 min.=10 max.=30408704 objects statistics summary");
			selectWindow("Results");
			Ar_Terminal = Table.getColumn("IntDen");
			//Save image
				selectWindow("Terminal");
				setMinAndMax(0, 1);
				saveAs("Tiff", dir2 + File.separator + Name +"_Terminal.tif");
			//Clear
				run("Clear Results");
				selectWindow(Name + "_Terminal.tif");
				close();
				selectImage("Objects map of MitoMask redirect to Terminal");
    			close();
			//print data
				selectWindow(Name + "_Result.csv");
				Table.setColumn("Counted Branch center no.", Ar_Branch);
				Table.setColumn("Junction no." , Ar_Junction);
				Table.setColumn("Terminal no.", Ar_Terminal);
				Table.setColumn("Branch Length(px)", Ar_BranchLpx);
				Table.setColumn("Branch Length(um)", Ar_BranchL_um);
	//Save
		selectImage("Skeleton of MitoMask");
		run("Grays");
		saveAs("Tiff", dir2 + File.separator + Name +"_Skeleton.tif");
		selectImage("Tagged skeleton");
		saveAs("Tiff", dir2 + File.separator + Name +"_Tagged Skeleton.tif");
		selectWindow(Name + "_Result.csv");
		saveAs("Results", dir2 + File.separator + Name +"_Result.csv");
	//Clear
		run("Close All");
//Generate channel merged img
	open(dir2 + File.separator + Name + "_Map.tif");
	rename("Map");
	bd= bitDepth();
	if (bd != 16) {
		run("16-bit");
	}
	open(dir2 + File.separator + Name + "_Raw.tif");
	rename("Raw");
	run("16-bit");
	open(dir2 + File.separator + Name + "_Terminal.tif");
	rename("Terminal");
	run("16-bit");
	setMinAndMax(0, 1);
	run("Apply LUT", "stack");
	run("Cyan");
	open(dir2 + File.separator + Name + "_Branch center.tif");
	rename("Branch");
	run("16-bit");
	setMinAndMax(0, 1);
	run("Apply LUT", "stack");
	run("Orange Hot");
	open(dir2 + File.separator + Name + "_Junction center.tif");
	rename("Junction");
	run("16-bit");
	setMinAndMax(0, 1);
	run("Apply LUT", "stack");
	run("Magenta");
	open(dir2 + File.separator + Name + "_Thickness.tif");
	rename("Thickness");
	run("Fire");
	open(dir2 + File.separator + Name + "_Tagged Skeleton.tif");
	rename("Skeleton");
	run("16-bit");
	run("Fire");
	run("Merge Channels...", "c1=Map c2=Raw c3=Terminal c4=Junction c5=Branch c6=Skeleton c7=Thickness create");
	selectImage("Composite");
	saveAs("Tiff", dir2 + File.separator + Name +"_Composite.tif");
//End
	run("Close All");
	te = getTime();
	tc = (te-ts)/1000/60;
	print(tifName + " analyzed in " + tc + " mins.");
	selectWindow(Name + "_Result.csv");
	run("Close");
	selectWindow("Results");
	run("Close");
	
	
	
	
/*
//Classify by thickness>8.72
	Ar_Hyper=newArray(0);
	HyperVol =0;
	TubularVol =0;
	for (i = 0; i < lengthOf(Ar_MaxLocalThickness); i++) {
		Tcs=Ar_MaxLocalThickness[i];
		if (Tcs>8.72) {
			Ar_Hyper = Array.concat(Ar_Hyper,"True");
			HyperVol=HyperVol+Ar_Vol_um3[i];
		}
		else {
			Ar_Hyper = Array.concat(Ar_Hyper,"F");
			TubularVol=TubularVol+Ar_Vol_um3[i];
		}
	}
	Table.setColumn("Hypertubular", Ar_Hyper);
	TotalVol = HyperVol + TubularVol;
	HyperVolPerc = HyperVol / TotalVol *100;
	TubularVolPerc = TubularVol/ TotalVol *100;
	print(tifName);
	print("HyperVol = " + HyperVol + " um^3  (" + HyperVolPerc +"%)");
	print("TubularVol = " + TubularVol +" um^3  (" + TubularVolPerc +"%)");
	print("   ");
*/	
/*
//Draw classify result
	selectWindow(Name +"_Map.tif");
	rename("Map");
	getMinAndMax(min, max);
	for (i = 1; i < max+1; i++) {
		arIdx=i-1;
		selectWindow("Map");
		run("Duplicate...", "title=MapTh duplicate");
		selectWindow("MapTh");
		rename(i);
		setThreshold(i, i, "raw");
		run("Convert to Mask", "background=Dark black");
		selectWindow(i);
		run("Divide...", "value=255 stack");
		Hyper = Ar_Hyper[arIdx];
		if (Hyper == "True") {
			selectWindow(i);
			run("Multiply...", "value=255 stack");
		}
		else{
			selectWindow(i);
			run("Multiply...", "value=129 stack");
		}
	}
	selectWindow("Map");
	close();
	for (i =2; i < max+1; i++) {
		selectWindow(i);
		rename("add");
		imageCalculator("Add stack", "1","add");
		selectWindow("add");
		close();	
	}
	selectWindow("1");
	run("Hi");
	saveAs("Tiff", dir2 + File.separator + Name +"_Classify result.tif");
*/

//setBatchMode("show");

