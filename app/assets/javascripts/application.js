// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .


jQuery.fn.loadFlashcardsForm = function(deck_id){
	var root = this;
	var flashcard = $('<div class="flashcard"></div>').appendTo(root);
	var sidea_field = $('<input type="text" id="form-flashcard-a"/>').appendTo(flashcard).focus().prepopulateElement('front');
	var sideb_field = $('<textarea type="text" id="form-flashcard-b"/>').appendTo(flashcard).prepopulateElement('back');	
	var submit = $('<input type="submit" id="form-flashcard-submit" value="new card"/>').appendTo(flashcard).click(function(e){
		var json = {
			deck_id: deck_id,
			side_a: $(sidea_field).val(),
			side_b: $(sideb_field).val()
		};
		e.preventDefault();
		$.ajax({
			url: '/api/flashcard/create.json',
			data: json,
			beforeSend: function(){
				$(root).text('loading...').addClass('loading');
			},
			success: function(data){
				$(root).text('').removeClass('loading').loadFlashcardsForm(deck_id);				
				$("#deck-flashcards").prepend(buildFlashcard(data));
			}
		})
		
	});
}


jQuery.fn.loadFlashcards = function(deck_id){
	var root = this;
	$.ajax({
		url: '/api/flashcards.json?deck_id='+deck_id,
		beforeSend: function(){
			$(root).text('loading...').addClass('loading');
		},
		success: function(data){
			$(root).text('').removeClass('loading');
			if (data.length==0){
				var deck_empty = $("<div id='deck-empty'></div>").text("empty deck").appendTo(root);
			}else{
				$.each(data, function(i, value){
					$(root).append(buildFlashcard(value));
				})
			}
		}
	})
}

jQuery.fn.editFlashcard = function(flashcard){
	var card_div = this;
	$(card_div).hide();

	var edit_div = $('<div class="flashcard"></div>').insertBefore(card_div);
	var sidea_field = $('<input type="text" id="form-flashcard-a"/>').val(flashcard.side_a).appendTo(edit_div);
	var sideb_field = $('<textarea type="text" id="form-flashcard-b"/>').val(flashcard.side_b).appendTo(edit_div);	
	var submit = $('<input type="submit" id="form-flashcard-submit" value="save"/>').appendTo(edit_div).click(function(e){
		var json = {
			id: flashcard.id,
			side_a: $(sidea_field).val(),
			side_b: $(sideb_field).val()
		};
		e.preventDefault();
		$.ajax({
			url: '/api/flashcard/edit.json',
			data: json,
			beforeSend: function(){
				$(edit_div).addClass('loading');
			},
			success: function(data){
				$(edit_div).removeClass('loading').remove();
				var saved_card = buildFlashcard(data);
				$(saved_card).insertBefore(card_div);
				$(card_div).remove();
			}
		})
		
	});
	var cancel = $('<input type="submit" value="cancel"/>').appendTo(edit_div).click(function(e){
		e.preventDefault();
		$(edit_div).remove();
		$(card_div).show();
	})
}

var confirmClickHandler = function (event) {
        if ($(event.currentTarget).data('isConfirming')) return;
        var message = event.currentTarget.attributes['data-confirm'].value;
        event.preventDefault();
        $('<div></div>')
                .html(message)
                .dialog({
                    title: "Confirm",
                    buttons: {
                        "Yes": function () {
                            $(this).dialog("close");
                            $(event.currentTarget).data('isConfirming', true);
                            event.currentTarget.click();
							$.ajax({
								url: '/api/flashcard/remove?id='+flashcard.id,
								success: function(){
									$(root).fadeOut().remove();
								}
							})
                            $(event.currentTarget).data('isConfirming', null);
                        },
                        "No": function () {
                            $(this).dialog("close");
                        }
                    },
                    modal: true,
                    resizable: false,
                    closeOnEscape: true
                });
    };


function buildFlashcard(flashcard){	
	var root = $('<div class="flashcard-div"></div>');
	var card = $('<div class="flashcard"></div>').appendTo(root);
	var sidea = $('<div class="flashcard-a"></div>').text(flashcard.side_a).appendTo(card);
	var sideb = $('<div class="flashcard-b"></div>').text(flashcard.side_b).appendTo(card);
	var stats = $('<div class="deck-flashcard-stats"></div>').appendTo(root);
	$(root).hover(function(){
		$(this).addClass('card-hovered');
		var tools = $('<div class="deck-flashcard-tools"></div>');
		var edit = $('<a href="#" class="deck-flashcard-edit"></a>').text('edit').appendTo(tools);
		var remove = $('<a href="#" class="deck-flashcard-remove"></a>')
			.attr('data-confirm', 'Are you sure you want to remove this card permanently?')
			.text('remove').appendTo(tools);
		$(edit).click(function(e){
			e.preventDefault();
			$(root).editFlashcard(flashcard);
		})
		$("body").delegate("[data-confirm]", "click", confirmClickHandler);
		$(tools).hide().appendTo(card).fadeIn();
		
	},function(){
		$(this).removeClass('card-hovered');
		$(this).find('.deck-flashcard-tools').fadeOut().remove();
	})
	return root;
}

jQuery.fn.prepopulateElement = function(defvalue) {
	var selector = this;
	$(selector).attr('placeholder', defvalue);
   	$(selector).each(function() {
       if($.trim(this.value) == "") {
           this.value = defvalue;
		   $(selector).addClass('prepopulate');
       }
   	});
 
   	$(selector).bind('change keyup focus click blur',function() {
       if(this.value == defvalue) {
			$(selector).removeClass('prepopulate');
            this.value = "";

       }
   	});
   
   	$(selector).blur(function() {
       if($.trim(this.value) == "") {
           this.value = defvalue;
		   $(selector).addClass('prepopulate');
       }
   	});
	return selector;
};