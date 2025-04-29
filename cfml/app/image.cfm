<cfscript>

    cfheader( name="Content-Type", value="application/json" );
    cfcontent( type="text/html; charset=utf-8" );
    if(structKeyExists(url,'img')){
        imgUrl = url['img']
    }else{
        imgUrl="https://avatars1.githubusercontent.com/u/10973141?s=280&v=4"
    }
    
    // Download the image into a CFML image variable.
    cfimage(action="read",name="sourceImage",source=imgUrl);
    // Get the mete data of the file
    cfimage(action="info",structname="original",source=sourceImage);
    
    // Maintain spect ratio.
    newWidth = 320;
    newHeight = (original.height/original.width) * newWidth;

    // resize the image
    cfimage(action="resize",source=sourceImage,name="resized",height=newHeight,width=newWidth,quality="1");
    // Deep copy the image, cfimage rotate rotates the original aswell as the output?  Meh, seams like an issue?
    copy = Duplicate(resized);
    writeOutput("<strong>Original Image:</strong><br/>" & resized & "<br/>");

    // Turn the image upside down
    cfimage(action="rotate",source=resized,angle="180",name="upsideDownImage");
    writeOutput("<strong>Rotated Image:</strong><br/>" & upsideDownImage & "<br/>");

    // Covert to graeyscale/
    imageGrayscale(copy);
    writeOutput("<strong>GreyScale Image:</strong><br/>" & copy);

</cfscript>