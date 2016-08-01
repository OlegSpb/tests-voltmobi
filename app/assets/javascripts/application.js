// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require turbolinks
//= require_tree .

$(document).ready(function(){
    var $doc = $(document);

    $doc.
        on('click', 'button.change-task-status-btn', function(e){
            var
                $this = $(this),
                parent = $this.parent();

            if(parent.prop('disabled')){
                return true;
            }

            parent.prop({disabled: true});
            parent.children().each(function(){
                $(this).addClass('disabled');
            });

            $.ajax({
                url: parent.data('url'),
                data: $this.data('params'),
                method: parent.data('method')
            }).
            done(function(data){

                var container = $(parent.data('container'));

                container.animate({opacity: 0}, function(){
                    var
                        new_classes = $(data).attr('class'),
                        old_classes = container.attr('class');

                    container.
                        removeClass(old_classes).
                        addClass(new_classes).
                        html($(data).html());

                    container.animate({opacity: 1});
                });
            }).
            always(function(){
                parent.prop({disabled: false});
                parent.children().each(function() {
                    $(this).removeClass('disabled');
                });
            });
        }).

        on('ajax:beforeSend', 'button.delete-something-btn', function(e){
            var
                $this = $(this);

            if($this.prop('disabled')){
                return false;
            }

            $this.prop({disabled: true});
        }).
        on('ajax:success', 'button.delete-something-btn', function(evt, data, status, xhr) {
            var
                $this = $(this),
                container = $($this.data('container'));

            container.animate({opacity: 0}).slideUp();
        }).
        on('ajax:complete', 'button.delete-something-btn', function(evt, xhr, status){
            var
                $this = $(this);

            $this.prop({disabled: false});
        });
});
