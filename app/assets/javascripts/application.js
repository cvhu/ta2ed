// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready(function(){
	$('.edit-hint').hide();
	$('.edit-button').hover(function(){
		$(this).find('.edit-hint').fadeIn();
	},function(){
		$(this).find('.edit-hint').fadeOut()
	})
});


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
	if ($('#deck-flashcard-new').length>0){
		$(root).hover(function(){
			$(this).addClass('card-hovered');		
			var tools = $('<div class="deck-flashcard-tools"></div>');
			var edit = $('<a href="#" class="deck-flashcard-edit"></a>').html('<span class="icon edit-icon"></span><span class="edit-hint">edit</span>').appendTo(tools);
			var remove = $('<a href="#" class="deck-flashcard-remove"></a>').text('remove').appendTo(tools);
			$(edit).click(function(e){
				e.preventDefault();
				$(root).editFlashcard(flashcard);
			})
			$(remove).click(function(e){
				e.preventDefault();
				$.ajax({
					url: '/api/flashcard/remove.json?id='+flashcard.id,
					success: function(){
						$(root).fadeOut();
					}
				})
			})
			$("body").delegate("[data-confirm]", "click", confirmClickHandler);
			$(tools).hide().appendTo(card).fadeIn();

		},function(){
			$(this).removeClass('card-hovered');
			$(this).find('.deck-flashcard-tools').fadeOut().remove();
		})		
	}
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


jQuery.fn.loadLearnAPI = function(deck_id, mode, state){
	var root = this;
	var partial_flag = $('#quiz-info-partial-flag').val();
	var quiz_count = $('#quiz-info-quiz-count').val();
	var front = [];
	$.each($('#quiz-info-front li'), function(i, v){
		front.push($(v).text());
	});
	var explored = [];
	$.each($('#quiz-info-explored li'), function(i, v){
		explored.push($(v).text());
	});
	var data = {
		deck_id: deck_id,
		mode: mode,
		state: state,
		partial_flag: partial_flag,
		quiz_count: quiz_count,
		front: front,
		explored: explored
	}
	
	
	if ((explored.length == $('.quiz-progress-item').length)||($('.timer-complete').length>0)){
		$(root).loadQuizSummary();
	}else{
		$.ajax({
			url:'/api/learn.json',//'?deck_id=8&state='+state+'&mode='+mode,
			data: data,
			beforeSend: function(){
				$(root).html('<div class="loading">loading...</div>');
			},
			success: function(data){
				$(root).text('');
				$('#quiz-info-partial-flag').val(data.partial_flag);
				$('#quiz-info-quiz-count').val(data.quiz_count);
				var front = $('#quiz-info-front').empty();
				$.each(data.front, function(i,v){
					$('<li></li>').html(v).appendTo(front);
				})
				var explored = $('#quiz-info-explored').empty();
				$.each(data.explored, function(i,v){
					$('<li></li>').html(v).appendTo(explored);
				})
				$('.quiz-progress-item').removeClass('current');				
				if (data.type=='quiz'){
					$(root).loadQuizView(data.attachment.quiz);
				}else if(data.type=='full'){
					$(root).loadFullView(data.attachment.flashcard);
				}else if(data.type=='partial'){
					$(root).loadPartialView(data.attachment.flashcards);
				}else{
					$(root).html('<div id="message" class="error"> Error </div>');
				}
			}
		})		
	}

}

function buildLearnButton(){
	var learn_button = $('<a href="#" id="next-button"></a>').text('next').click(function(e){
		e.preventDefault();
		$('#learn-wrapper').loadLearnAPI($('#quiz-info-deck-id').text(),$('#quiz-info-mode').text() , 'ongoing');
	});
	return learn_button;
}

jQuery.fn.loadQuizSummary = function(){
	var root = this;
	$('#quiz-progress').fadeOut();
	$(root).empty();
	var summary = $('<div id="quiz-summary"></div>').appendTo(root);
	var title = $('<div id="quiz-summary-title"></div>').html('Summary').appendTo(summary);
	$.each($('.quiz-progress-item'), function(i,v){
		var item = $('<div class="quiz-summary-item"></div>').appendTo(summary);
		var name = $('<div class="quiz-summary-item-name"></div>').appendTo(item).html($(v).attr('name'));
		var right = $(v).find('.quiz-right').length;
		var wrong = $(v).find('.quiz-wrong').length;
		var score = $('<div class="quiz-summary-item-score"></div>').appendTo(item);
		var rate = right*1.0/(right+wrong);
		var right_width = $(score).width()*rate;
		var wrong_width = $(score).width()*(1-rate);
		$('<div class="quiz-summary-item-score-right quiz-right"></div>').css('width',right_width).appendTo(score);
		$('<div class="quiz-summary-item-score-wrong quiz-wrong"></div>').css('width',wrong_width).appendTo(score);
		$('<div class="quiz-summary-item-rate"></div>').html((rate*100).toFixed(2)+'%').appendTo(item);
		
	})
	
}

jQuery.fn.loadQuizView = function(quiz){
	var root = this;
	pushHeaderMessage('QUIZ: Please Choose the Correct Answer', 'hint');
	var qv = $('<div id="quiz-view" class="learn-view"></div>').appendTo(root);
	var question = $('<div id="question"></div>').text(quiz.question).appendTo(qv);
	var choices = $('<div id="choices"></div>').appendTo(qv);
	$.each(quiz.choices, function(i, choice){
		if (choice == quiz.answer){
			var choice_button = $('<a class="choice answer"></a>').attr('href', quiz.correct_url).text(choice).appendTo(choices);
		}else{
			var choice_button = $('<a class="choice"></a>').attr('href', quiz.wrong_url).text(choice).appendTo(choices);
		}
	})		
	var next_button = buildLearnButton();
	$(next_button).hide().appendTo(qv);	
	progress.updateItem(quiz.question_id, quiz.question, 'quiz');
	$(".choice").click(function(e){
		e.preventDefault();
		$('#header-messages').children().slideUp();
		$.ajax({
			url: $(this).attr('href'),
			success: function(){
				$("#next-button").fadeIn();
			}
		})
		$(".choice").removeAttr("href");
		if (!$('#next-button').is(":visible")){
			if ($(this).hasClass('answer')){
				$(this).addClass('correct');
				progress.updateItem(quiz.question_id, quiz.question, 'quiz-right');
				var feedback = $('<div class="feedback-correct"></div>').text('correct!').appendTo($("#choices"));
				$('#quiz-info-explored').append($('<li></li>').html(quiz.question_id));
			}else{
				progress.updateItem(quiz.question_id, quiz.question, 'quiz-wrong');
				$(this).addClass('wrong');
				$(".answer").addClass('correct');
				var feedback = $('<div class="feedback-wrong"></div>').text('Did you forget this one?').appendTo($("#choices"));
				$('#quiz-info-front').append($('<li></li>').html(quiz.question_id));
			}		
		}
	})
	
}

jQuery.fn.loadPartialView = function(flashcards){
	var root = this;
	var pv = $('<div id="partial-view" class="learn-view"></div>').appendTo(root);
	$.each(flashcards, function(i, flashcard){
		progress.updateItem(flashcard.id, flashcard.side_a, 'partial');
		var flashcard_div = $('<div class="flashcard"></div>').appendTo(pv);
		var side_a = $('<div class="flashcard-a"></div>').html(flashcard.side_a).appendTo(flashcard_div);
		var remind_me = $('<a href="#" class="partial-remind"></a>').html('remind me').appendTo(flashcard_div).click(function(e){
			e.preventDefault();
			$(this).hide();
			progress.updateItem(flashcard.id, 'partial-forgot');
			var side_b = $('<div class="flashcard-b"></div>').html(flashcard.side_b).hide().appendTo(flashcard_div).fadeIn();
		})
	})
	var next_button = buildLearnButton();
	$(next_button).appendTo(pv);	
	
}

jQuery.fn.loadFullView = function(flashcard){
	var root = this;
	var fv = $('<div id="full-view" class="learn-view"></div>').appendTo(root);
	var flashcard_div = $('<div id="flashcard"></div>').appendTo(fv);
	var side_a = $('<div id="flashcard-a"></div>').html(flashcard.side_a).appendTo(flashcard_div);
	var side_b = $('<div id="flashcard-b"></div>').html(flashcard.side_b).appendTo(flashcard_div);
	var next_button = buildLearnButton();
	progress.updateItem(flashcard.id, flashcard.side_a, 'full');
	$(next_button).appendTo(fv);
	
}

function pushHeaderMessage(text, type){	
 	$("#header-messages").remove();
	var messages = $('<div id="header-messages"></div>').appendTo('#content');
	var new_message = $('<div class="messages"></div>').addClass(type).html(text).hide().appendTo(messages).fadeIn();
	var exit = $('<a href="#" id="dismiss-messages-button" class="icon close-icon"></a>').appendTo(new_message).click(function(e){
		e.preventDefault();
		$(new_message).slideUp();
	})	
}

function pushSlideMessage(text, type){	
 	$("#slide-messages").remove();
	var messages = $('<div id="slide-messages"></div>').appendTo('body');
	var new_message = $('<div class="messages"></div>').addClass(type).html(text).hide().appendTo(messages).fadeIn('slow').fadeOut('slow').fadeIn('slow');
	var exit = $('<a href="#" id="dismiss-messages-button" class="icon close-icon"></a>').appendTo(new_message).click(function(e){
		e.preventDefault();
		$(new_message).slideUp();
	})
	
}


jQuery.fn.prepopulateDefault = function(){
	var root = this;
	$(root).find('input').focus(function(){
		$(root).addClass('prepopulated-field-focus');
	})
	
	$(root).find('input').blur(function(){
		$(root).removeClass('prepopulated-field-focus');
		if ($(this).val()==''){
			$(root).find('label').fadeIn();
		}
	})
	
	$(root).find('input').keyup(function(){
		if ($(this).val()==''){
			$(root).find('label').fadeIn();
		}else{
			$(root).find('label').hide();	
		}				
	})			
}
