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
	var flashcard = $('<div class="deck-flashcard"></div>').appendTo(root);
	var sidea_field = $('<input type="text" id="form-flashcard-a"/>').appendTo(flashcard);
	var sideb_field = $('<input type="text" id="form-flashcard-b"/>').appendTo(flashcard);	
	var submit = $('<input type="submit" id="form-flashcard-submit" value="new card"/>').appendTo(root).click(function(e){
		var json = {
			deck_id: deck_id,
			side_a: $(sidea_field).val(),
			side_b: $(sideb_field).val()
		};
		e.preventDefault();
		$.ajax({
			url: '/flashcard/create.json',
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
		url: '/flashcards.json?deck_id='+deck_id,
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

function buildFlashcard(flashcard){
	var root = $('<div class="deck-flashcard-div"></div>');
	var card = $('<div class="deck-flashcard"></div>').appendTo(root);
	var sidea = $('<div class="deck-flashcard-a"></div>').text(flashcard.side_a).appendTo(card);
	var sideb = $('<div class="deck-flashcard-b"></div>').text(flashcard.side_b).appendTo(card);
	var stats = $('<div class="deck-flashcard-stats"></div>').appendTo(root);
	var views = $('<div class="deck-flashcard-viewcount"></div>').html(flashcard.views + '<div class="subscript">views</div>').appendTo(stats);
	return root;
}