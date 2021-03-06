<style type="text/css">
.sortableHandle {
	cursor: move;
}
.hiddenStyle {
	display: none;
}
.savedDiv {
	text-align: center;
	font-weight: bold;
	font-style: italic;
}
#goodSavedDiv {
	color: green;
}
#badSavedDiv {
	color: red;
}
#orderSpinnerDiv {
	float: right;
	width: 16px;
	position: relative;
	top: 10px;
}
label {
    font-weight: bold;
}
.disabledGrey {
    -webkit-filter: grayscale(100%); /* Chrome 19+, Safari 6+, Safari 6+ iOS */
    filter: gray; /* IE6-9 */
    filter: url("data:image/svg+xml;utf8,<svg xmlns=\'http://www.w3.org/2000/svg\'><filter id=\'grayscale\'><feColorMatrix type=\'matrix\' values=\'0.3333 0.3333 0.3333 0 0 0.3333 0.3333 0.3333 0 0 0.3333 0.3333 0.3333 0 0 0 0 0 1 0\'/></filter></svg>#grayscale"); /* Firefox 10+, Firefox on Android */
}
</style>
<script type="text/javascript">
//<![CDATA[
$("document").ready(function() {
	var spinnerOpts = {
		lines: 12, // The number of lines to draw
		length: 3, // The length of each line
		width: 2, // The line thickness
		radius: 4, // The radius of the inner circle
		color: '#000', // #rbg or #rrggbb
		speed: 2, // Rounds per second
		trail: 60, // Afterglow percentage
		shadow: false // Whether to render a shadow
	};
	$.fn.htmlInclusive = function() { return $('<div />').append($(this).clone()).html(); }

    var startup = true;
	
	var startSpin = function() {
		$("#orderSpinner").spin(spinnerOpts);
		$("#orderSpinnerDiv").fadeIn("fast");
	}
	
	var stopSpin = function() {
			$("#orderSpinnerDiv").fadeOut("fast", function() {
				$("#orderSpinner").spin();
			});
	}
	
	var lockBox = function(id) {
		$("#cfield-field-title-" + id).attr("readonly", "readonly");
		$("#cfield-field-description-" + id).attr("readonly", "readonly");
		$("#cfield-field-typelist-" + id).attr("disabled", "disabled");
		$("#cfield-field-defaultvalue-" + id).attr("readonly", "readonly");
		$("#cfield-field-regex-" + id).attr("readonly", "readonly");
		$("#cfield-field-required-" + id).attr("disabled", "disabled");
		$("#saveBtn-" + id).attr("disabled", "disabled");
        $("#cfield-field-description-" + id).attr("readonly", "readonly");
        $("#cfield-typeopt-min-" + id).attr("readonly", "readonly");
        $("#cfield-typeopt-max-" + id).attr("readonly", "readonly");
        $("#cfield-typeopt-step-" + id).attr("readonly", "readonly");
	}
	
	var unlockBox = function(id) {
		$("#saveBtn-" + id).removeAttr("disabled");
		$(".cfield-field-" + id).removeAttr("disabled");
		$(".cfield-field-" + id).removeAttr("readonly");
	}

    var doTypelistLoop = function() {
        var typelistlength = $(".cfield-field-typelist").length;
        $(".cfield-field-typelist").each(function(index) {
            $(this).change();
            if(index == typelistlength - 1) {
                startup = false;
            }
        });
    }
	
	var onFieldChangeEvent = function(paramId) {
        if(startup) {
            return;
        }
		var id;
		if(!isNaN(parseFloat(paramId)) && isFinite(paramId)) {
			id = paramId;
		}
		else {
			id = this.id.split("-")[3];
		}
		$(".saveBtnDivStatus-" + id).slideUp();
		$("#saveBtnDiv-" + id).slideDown();
	}
	$("#newCustomFieldLink").click(function() {
        $("#hiddenFieldBox-new").show();
		$("#orderfieldbox-new").slideToggle();
	});
	$("#sortableDiv").sortable({
		change: function(event, ui) {
			$("#saveOrderChangesDiv").slideDown();
		}
	});

	var editOrderBtnClickEvent = function() {
		var id = this.id.split("-")[1];
		$("#hiddenFieldBox-"+id).slideToggle();
	}

    var delOrderBtnClickEvent = function() {
        var id = this.id.split("-")[1];
        if(id == "new") {
            return;
        }
        var name = $("#orderTitle-" + id + " a").html();
        if(confirm("Are you sure you want to delete the \""+name+"\" field?\n"
                + "This will also remove any user data associated with it.")) {
            lockBox(id);
            startSpin();
            var json = {
                id: id
            }
            json[csrfMagicName] = csrfMagicToken;
            $.post("<AJAX>?function=deleteCustomField", json, function (data) {
                if(data == "1") {
                    $("#orderfieldbox-" + id).slideUp(function() {
                        $("#orderfieldbox-" + id).remove();
                        stopSpin();
                    });
                }
                else {
                    unlockBox(id);
                    stopSpin();
                }
            });
        }
    }
	
	$("#saveOrderChangesBtn").click(function() {
		$(this).attr("disabled", "disabled");
		startSpin();
		$("#atBottomDiv").slideUp(function() {
			$(".savedDiv").hide();
			var order = [];
            var orderi = 0;
			$(".orderfieldbox").each(function(index) {
                var ofbid = $(this).attr('id').split("-")[1];
                if(ofbid != "new") {
                    order[orderi++] = ofbid;
                }
			});
            var json = {
                table: 'orderfields',
                order: order.join(',')
            }
            json[csrfMagicName] = csrfMagicToken;
			$.post("<AJAX>?function=setOrderOfRows", json, function(data) {
				if(data == "1") {
					$("#goodSavedDiv").show();
				}
				else {
					$("#badSavedDiv").show();
				}
				$("#saveOrderChangesBtn").removeAttr("disabled");
				$("#atBottomDiv").slideDown();
				stopSpin();
			});
		});
	});

	var onFieldTypelistChange = function() {
		var id = this.id.split("-")[3];
		// Needs testing with IE. Bypassing jQuery for compatibility
		if(this.value == "password") {
			document.getElementById("cfield-field-defaultvalue-" + id).setAttribute("type", "text");
			$(".cfield-selectstuff-optdiv-" + id).slideUp();
            $(".cfield-typeopt-typeoptdiv-" + id).slideUp();
            $("#cfield-field-defaultoption-" + id).fadeOut(function() {
                $("#cfield-field-defaultvalue-" + id).fadeIn();
            });
            $(".tdregexpdiv-" + id).slideDown();
		}
		else if(this.value == "select") {
			$(".cfield-selectstuff-optdiv-" + id).slideDown();
            $("#cfield-field-defaultvalue-" + id).fadeOut(function() {
                $("#cfield-field-defaultoption-" + id).fadeIn();
            });
            $(".cfield-typeopt-typeoptdiv-" + id).slideUp();
            $(".tdregexpdiv-" + id).slideUp();
		}
        else if(this.value == "number" || this.value == "range" || this.value == "week") {
            document.getElementById("cfield-field-defaultvalue-" + id).setAttribute("type", this.value);
            $(".cfield-selectstuff-optdiv-" + id).slideUp();
            $(".cfield-typeopt-typeoptdiv-" + id).slideDown();
            $("#cfield-field-defaultoption-" + id).fadeOut(function() {
                $("#cfield-field-defaultvalue-" + id).fadeIn();
            });
            if(this.value == "range") {
                $(".tdregexpdiv-" + id).slideUp();
                return;
            }
            $(".tdregexpdiv-" + id).slideDown();
        }
		else {
			document.getElementById("cfield-field-defaultvalue-" + id).setAttribute("type", this.value);
			$(".cfield-selectstuff-optdiv-" + id).slideUp();
            $(".cfield-typeopt-typeoptdiv-" + id).slideUp();
            $("#cfield-field-defaultoption-" + id).fadeOut(function() {
                $("#cfield-field-defaultvalue-" + id).fadeIn();
            });
            if(this.value == "checkbox") {
                $(".tdregexpdiv-" + id).slideUp();
                return;
            }
            $(".tdregexpdiv-" + id).slideDown();
		}
	};

    var onTypeOptInputChangeEvent = function() {
        var split = this.id.split("-");
        $("#cfield-field-defaultvalue-" + split[3]).attr(split[2], $(this).val());
    }

	var bindActionsAgain = function() {
		$(".cfield-action-upoption").unbind('click');
		$(".cfield-action-downoption").unbind('click');
		$(".cfield-action-renameoption").unbind('click');
		$(".cfield-action-deleteoption").unbind('click');
        $(".cfield-action-newoption").unbind('click');
		$(".cfield-action-upoption").click(onOptionUpClick);
		$(".cfield-action-downoption").click(onOptionDownClick);
		$(".cfield-action-renameoption").click(onOptionRenameClick);
		$(".cfield-action-deleteoption").click(onOptionDeleteClick);
        $(".cfield-action-newoption").click(onOptionNewClick);
	}

    var bindEssentialActionsAgain = function() {
        $(".orderEditBtn").unbind('click');
        $(".orderTitle").unbind('click');
        $(".orderDelBtn").unbind('click');
        $(".cfield-field").unbind('change');
        $(".cfield-typeopt-input").unbind('change');
        $(".cfield-field-typelist").unbind('change');
        $(".saveBtn").unbind('click');
        $(".orderEditBtn").click(editOrderBtnClickEvent);
        $(".orderTitle").click(editOrderBtnClickEvent);
        $(".orderDelBtn").click(delOrderBtnClickEvent);
        $(".cfield-field").change(onFieldChangeEvent);
        $(".cfield-typeopt-input").change(onTypeOptInputChangeEvent);
        $(".cfield-field-typelist").change(onFieldTypelistChange);
        $(".saveBtn").click(onSaveButtonClick);
    }

	var onOptionRenameClick = function() {
        var id = this.id.split("-")[3];
		var jTitle = $("#cfield-tr-selecttr-" + id + " td:nth-child(1)");
		var title = prompt('New title of "' + jTitle.html() + '"');
		if(title == undefined || title == null) {
			return;
		}
		else if(title == "") {
			alert("The title cannot be blank.");
			return;
		}
		jTitle.text(title);
        $("#cfield-field-defaultoption-option-" + id).text(title);
		onFieldChangeEvent(this.id.split("-")[3]);
	}

	var onOptionUpClick = function() {
		var clicked = $("#cfield-tr-selecttr-" + this.id.split("-")[3]);
		if(clicked.prevAll().length > 0) {
			clicked.prev().before(clicked.htmlInclusive());
			clicked.remove();
			bindActionsAgain();
			onFieldChangeEvent(this.id.split("-")[3]);
		}
	}

	var onOptionDownClick = function() {
		var clicked = $("#cfield-tr-selecttr-" + this.id.split("-")[3]);
		if(clicked.nextAll().length > 0) {
			clicked.next().after(clicked.htmlInclusive());	
			clicked.remove();
			bindActionsAgain();
			onFieldChangeEvent(this.id.split("-")[3]);
		}
	}

    var onOptionDeleteClick = function() {
        var id = this.id.split("-")[3];
        $("#cfield-tr-selecttr-" + id).remove();
        $("#cfield-field-defaultoption-option-" + id).remove();
        bindActionsAgain();
        onFieldChangeEvent(this.id.split("-")[3]);
    }

    var globalOptionIdCounter = %GLOBALSELECTOPTIONCOUNTER%;

    var onOptionNewClick = function() {
        var id = this.id.split("-")[3];
        var title = prompt("The title of your new option:");
        if(title == undefined || title == null || title == "") {
            return;
        }
        $("#cfield-tbody-selectoptions-" + id).append('<tr id="cfield-tr-selecttr-'+globalOptionIdCounter+'"><td>'+escapeHtml(title)+'</td><td><div style="text-align:right;font-weight:bold;width:100%;"><a id="cfield-action-upoption-'+globalOptionIdCounter+'" class="cfield-action-upoption" href="javascript:void(0);">[Up]</a> <a id="cfield-action-downoption-'+globalOptionIdCounter+'" class="cfield-action-downoption" href="javascript:void(0);">[Down]</a> <a id="cfield-action-renameoption-'+globalOptionIdCounter+'" class="cfield-action-renameoption" href="javascript:void(0);">[Rename]</a> <a id="cfield-action-deleteoption-'+globalOptionIdCounter+'" class="cfield-action-deleteoption" href="javascript:void(0);">[Delete]</a></div></td></tr>');
        $("#cfield-field-defaultoption-" + id).append('<option id="cfield-field-defaultoption-option-'+globalOptionIdCounter+'" value="'+escapeHtml(title)+'">'+escapeHtml(title)+'</option>');
        globalOptionIdCounter++;
        // Re-bind events to new elements
        bindActionsAgain();
        onFieldChangeEvent(id);
    }


    var onSaveButtonClick = function() {
        var id = this.id.split("-")[1];
        $(".saveBtnDivStatus-" + id).slideUp();

        if($("#cfield-field-title-" + id).val() == "") {
            alert("A title is required.");
            return;
        }

        $(this).attr("disabled", "disabled");
        $(this).html("Saving...");
        lockBox(id);
        startSpin();
        var json = {
            id: id,
            title: $("#cfield-field-title-" + id).val(),
            description: $("#cfield-field-description-" + id).val(),
            type: $("#cfield-field-typelist-" + id).val(),
            selectopt: $("#cfield-tbody-selectoptions-" + id).html(),
            defaultvalue: $("#cfield-field-defaultvalue-" + id).attr('type') == 'checkbox' ?
                    $("#cfield-field-defaultvalue-" + id).is(':checked') : $("#cfield-field-defaultvalue-" + id).val(),
            regex: $("#cfield-field-regex-" + id).val(),
            required: $("#cfield-field-required-" + id).is(':checked'),
            min: $("#cfield-typeopt-min-" + id).val(),
            max: $("#cfield-typeopt-max-" + id).val(),
            step: $("#cfield-typeopt-step-" + id).val(),
            defaultopt: $("#cfield-field-defaultoption-" + id).val(),
            counter: globalOptionIdCounter
        };
        json[csrfMagicName] = csrfMagicToken;
        $.post("<AJAX>?function=updateCustomField", json, function(data) {
            if(!data.error) {
                if(id == "new") {
                    $("#orderfieldbox-new").slideUp(function() {
                        // Restore new box
                        $("#orderfieldbox-new").html(newBoxHtml);
                        bindActionsAgain();
                        bindEssentialActionsAgain();
                        $("#cfield-field-typelist-new").change();
                        doTooltip("#orderfieldbox-new");
                    });
                    globalOptionIdCounter = data.counter;
                    $("<div></div>").prependTo("#sortableDiv").hide().prepend(data.newbox).slideDown();
                    bindActionsAgain();
                    bindEssentialActionsAgain();
                    $("#cfield-field-typelist-" + data.id).change();
                    doTooltip("#orderfieldbox-" + data.id);
                }
                else {
                    $("#saveBtnDivGood-" + id).slideUp(function() {
                        $("#saveBtnDivGood-" + id).html(data.msg != null ? data.msg : "Saved!").slideDown();
                    });
                    if($("#cfield-field-title-" + id).val() != $("#orderTitle-"+id+" a").html()) {
                        $("#orderTitle-"+id+" a").fadeOut(function() {
                            $("#orderTitle-"+id+" a").text($("#cfield-field-title-" + id).val()).fadeIn();
                        });
                    }
                    var star = $("#cfield-field-required-" + id).is(':checked');
                    if((star && $("#orderTitle-Req-" + id).html() != "*") || (!star && $("#orderTitle-Req-" + id).html() == "*")) {
                        $("#orderTitle-Req-" + id).fadeOut(function() {
                            $("#orderTitle-Req-" + id).html($("#cfield-field-required-" + id).is(':checked') ? "*" : "").fadeIn();
                        });
                    }
                }
            }
            else {
                $("#saveBtnDivBad-" + id).html(data.error ? data.msg : "An unknown error has occurred. :( Your changes may or may not have been saved.").fadeIn();
            }
            $("#saveBtn-" + id).html("Save Changes");
            unlockBox(id);
            stopSpin();
        }, "json");
    }

    function escapeHtml(unsafe) {
        return unsafe
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
    }
    var newBoxHtml = $("#orderfieldbox-new").html();
    bindActionsAgain();
    bindEssentialActionsAgain();
    doTypelistLoop();
    $("#orderfieldbox-new").removeClass("sortableHandle");
});
//]]>
</script>

<a href="javascript:void(0)" id="newCustomFieldLink"><strong><img src="<ICONDIR>add.png" /> New Custom Field</strong></a>
<div id="orderSpinnerDiv" class="hiddenStyle"><a id="orderSpinner" class="orderSpinner"></a></div>
%NEWBOX%
<div id="sortableDiv">