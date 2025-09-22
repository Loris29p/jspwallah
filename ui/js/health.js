// Progress bar management for health and armor
$(function() {
    // Variables to track current progress
    let progressTimer = null;
    let progressType = null;
    let startTime = 0;
    let duration = 0;
    
    // Listen for messages from the game script
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        if (data.type === 'startProgress') {
            // Start progress animation
            startProgress(data.progressType, data.duration);
        } else if (data.type === 'cancelProgress') {
            // Cancel current progress
            cancelProgress();
        } else if (data.type === 'hideProgress') {
            // Hide progress bar without animation
            hideProgress();
        }
    });
    
    // Handle key press for canceling
    $(document).keyup(function(e) {
        if (e.keyCode === 88 && progressTimer) { // 'X' key
            // Send cancel event back to LUA
            $.post('https://gamemode/cancelProgress', JSON.stringify({
                progressType: progressType
            }));
            cancelProgress();
        }
    });
    
    // Start progress animation
    function startProgress(type, time) {
        // Clear any existing progress
        cancelProgress();
        
        // Set tracking variables
        progressType = type;
        duration = time;
        startTime = Date.now();
        
        // Setup progress bar appearance based on type
        if (type === 'medkit') {
            $('.progress-container').removeClass('armor').addClass('health');
            $('.progress-label').text('Health');
        } else if (type === 'kevlar') {
            $('.progress-container').removeClass('health').addClass('armor');
            $('.progress-label').text('Armor');
        } else if (type === 'bandage') {
            $('.progress-container').removeClass('health').addClass('armor');
            $('.progress-label').text('Bandage');
        }
        
        // Show progress container
        $('.progress-container').fadeIn(300);
        $('.progress-bar').css('width', '0%');
        $('.progress-cancel-hint').show();
        
        // Start animation
        updateProgress();
        
        // Set interval to update progress
        progressTimer = setInterval(updateProgress, 50);
    }
    
    // Update progress bar
    function updateProgress() {
        const elapsed = Date.now() - startTime;
        const progress = Math.min((elapsed / duration) * 100, 100);
        
        $('.progress-bar').css('width', progress + '%');
        
        // Check if completed
        if (progress >= 100) {
            completeProgress();
        }
    }
    
    // Complete progress
    function completeProgress() {
        clearInterval(progressTimer);
        progressTimer = null;
        
        // Notify LUA that progress is complete
        $.post('https://gamemode/progressComplete', JSON.stringify({
            progressType: progressType
        }));
        
        // Hide with animation
        $('.progress-container').fadeOut(300, function() {
            $('.progress-bar').css('width', '0%');
        });
        progressType = null;
    }
    
    // Cancel progress
    function cancelProgress() {
        if (progressTimer) {
            clearInterval(progressTimer);
            progressTimer = null;
            
            // Hide with animation
            $('.progress-container').fadeOut(300, function() {
                $('.progress-bar').css('width', '0%');
            });
            progressType = null;
        }
    }
    
    // Hide progress without animation
    function hideProgress() {
        if (progressTimer) {
            clearInterval(progressTimer);
            progressTimer = null;
        }
        
        $('.progress-container').hide();
        $('.progress-bar').css('width', '0%');
        progressType = null;
    }
});
