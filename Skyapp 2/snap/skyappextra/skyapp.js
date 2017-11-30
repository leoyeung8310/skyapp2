//alert("Hello! I am an alert box!!");
//---gui.js, skyapp1
function addOne(x){
    return 1+x;
}

BlockMorph.prototype.sendToPeers = function () {
    try {
        var str;
        var arr = [];
        var prefix = "skyappios:sendToPeers";
        
        //text output in IOS
        var o1 = "Script:";
        var block = this;
        do {
            if (block != this)
                o1 += ",";
            //selector is command's name, toString() is another option gives detail;
            o1 += block.selector;
            block = block.nextBlock();
        } while (block);
        arr.push(o1);
        
        //text to transfer back to snap's
        ide = this.parentThatIsA(IDE_Morph);
        var o2 = ide.serializer.serializeBlocks(this,1);
        arr.push(o2);

        str = prefix+":"+JSON.stringify(arr);
        
        window.location=str;
    
    } catch (err) {
        alert('Load failed: ' + err);
    }
};

function pasteACommand(cmd){
    try {
        //var prefix = "skyappios:sendToPeers:";
        //cut prefix, remove "%"
        //var script = decodeURIComponent(cmd).slice(prefix.length);
        //alert("cmd = "+cmd);
        //
        
        var script = decodeURIComponent(cmd);
        //alert("script = "+script);
        
        //find current snap's IDE
        var ide = skyappIDE;
        
        //load script in current Sprite's scripts, parse() do xmlstring translate
        ide.serializer.loadScripts(ide.currentSprite.scripts, ide.serializer.parse(script));
        ide.createCorral();
        ide.fixLayout();
        
    } catch (err) {
        alert('Load failed: ' + err);
    }
}

//function utf8_to_b64(str) {
//    return window.btoa(unescape(encodeURIComponent(str)));
//}

//function b64_to_utf8(str) {
//    return decodeURIComponent(escape(window.atob(str)));
//}
