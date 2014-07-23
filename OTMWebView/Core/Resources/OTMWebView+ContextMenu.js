//
// OTMWebView+ContextMenu.js
//
// Copyright (c) 2014 Ryan Coffman
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

document.body.style.webkitTouchCallout = "none";

var count = 0;

function otm_uniqueId() {
	
	return count++;
}

function otm_elementsAtPoint(x, y) {

	var e = document.elementFromPoint(x, y);

	var elements = [];
	while (e) {

		if (!e.id) {
			e.id = "__otm__" + otm_uniqueId();
		}
		var attributes = {
			tagName: e.tagName,
			documentURL: e.ownerDocument.documentURI
		};

		for (var i = 0; i < e.attributes.length; i++) {

			var attr = e.attributes[i];
			attributes[attr.name] = attr.value;
		}
				
		elements.push(attributes);
		
		e = e.parentElement;
	}

	return JSON.stringify(elements);
}

function otm_imageDataWithImageId(id, scale) {
	
	var img = document.getElementById(id);

	var canvas = document.createElement("canvas");
	
	canvas.width = img.width * window.devicePixelRatio;
	canvas.height = img.height * window.devicePixelRatio;
	
	canvas.getContext("2d").drawImage(img, 0.0, 0.0);
	
	return canvas.toDataURL("image/png");
}
