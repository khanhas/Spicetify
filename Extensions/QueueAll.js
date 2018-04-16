// START METADATA
// NAME: Queue All
// AUTHOR: khanhas
// DESCRIPTION: Add Queue All button in every album carousel.
// END METADATA
'use strict';
(function QueueAll() {
    if (!chrome.addToQueue || !chrome.libURI) {
        setTimeout(QueueAll, 1000);
        return;
    }
    var oldURI;
    var curActive;
    var uris;
    var index = -1;
    var addingElement;
    const COLLECTION_CLASSES = "div.crsl-item.col-xs-12.col-sm-12.col-md-12.col-lg-12"                  
    const ARTIST_CLASSES = ".albums, .singles, .appears_on"
    const MOUNT_CLASSES = ".GlueCarousel"
    const CARD_CLASSES = ".card, header.header.header-inline.header-album, .GlueCard"
    const QUEUEALL_BUTTON = '<button queue-all-done="0" class="custom-queue-all button button-with-stroke button-add" style="font-weight:300;margin-left:20px">Queue all</button>'
    const BROWSE_REGEXP = new RegExp(/spotify:app:browse:(discover|releases|podcasts)/)
    const ARTIST_REGEXP = new RegExp(/spotify:app:artist/)
    setInterval(() => {
        curActive = $("iframe.active")
        if (curActive.length > 0) {
            var curURI = curActive.attr("data-app-uri");
            if (curURI !== oldURI) {
                var doc = curActive.contents();
                if (!doc) return;
                oldURI = curURI;
                if (BROWSE_REGEXP.test(curURI)) {
                    findCarousel(doc, COLLECTION_CLASSES);
                } else if (ARTIST_REGEXP.test(curURI)) {
                    findCarousel(doc, ARTIST_CLASSES);
                }
            }
            return;
        }

        curActive = $("#mount-album.active")
        if (curActive.length > 0) {
            var curURI = curActive.attr("data-ta-id");
            if (curURI !== oldURI) {
                var doc = curActive.contents();
                if (!doc) return;
                oldURI = curURI;
                if (curURI == "album-page") {
                    findCarousel(doc, MOUNT_CLASSES);
                }
            }
            return;
        }
        
    }, 1000)

    function findCarousel(activeDoc, classes, retry = 0) {
        if (retry > 10) return;
        var crslItems = activeDoc.find(classes)
        if (crslItems.length > 0) {
            crslItems.each(function () {
                appendQueueAll($(this));
            })
        } else {
            setTimeout(()=>findCarousel(activeDoc, classes, ++retry), 1000);
        }
    }

    function queue(uris, index) {
        if (index < uris.length){
            addingElement.innerText = "Adding " + (index + 1) + "/" + uris.length
            chrome.addToQueue(uris[index], error => {
                if (error) {
                    console.log(error);
                } else {
                    console.log("Added", uris[index]);
                }    
                queue(uris, ++index)
            });
        } else {
            addingElement.innerText = "Added";
            setTimeout(() => addingElement.innerText = "Queue all", 2000);
        }
    }

    function appendQueueAll(item) {
        var uris = [];
        item.find(CARD_CLASSES).each(function() {
            var uri = $(this).attr("data-uri");
            if (uri && filterURI(uri))
                uris.push(uri);
        });

        if (item.find("button.custom-queue-all").length == 0 &&
            uris.length > 0) {
            item.find("h2").append(QUEUEALL_BUTTON)
        }

        item.find("button.custom-queue-all").each(function () {
            if ($(this).attr("queue-all-done") == "0") {
                $(this).attr("queue-all-done", "1");
                $(this).click(function() {
                    addingElement = $(this)[0];
                    queue(uris, 0);
                })
            }
        })
    }

    function filterURI(uri) {
        uri = chrome.libURI.from(uri)
        if (uri.type === chrome.libURI.Type.ALBUM ||
            uri.type === chrome.libURI.Type.TRACK ||
            uri.type === chrome.libURI.Type.EPISODE) {
            return true;
        } else {
            return false;
        }
    }
        
})()