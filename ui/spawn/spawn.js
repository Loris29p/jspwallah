window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'displayTextSpawn') {
        if (data.color) {
            AddLine(data.message, {color: data.color, typingSpeed: data.typingSpeed})
        } else {
            AddLine(data.message, {typingSpeed: data.typingSpeed})
        }
    } else if (data.type === 'deleteAllText') {
        DeleteAllLine();
    }
});


document.addEventListener('DOMContentLoaded', function() {
  // Create the container if it doesn't exist
  if (!document.getElementById('text-container')) {
    const container = document.createElement('div');
    container.id = 'text-container';
    document.body.appendChild(container);
  }
  
});

/**
 * Add a line of text with typing effect
 * @param {string} message - Text message to display with optional color tags (^RED, ^BLUE, ^GREEN, etc. or ^#HEXCODE)
 * @param {Object} options - Configuration options
 * @param {string} options.color - Default color of the text (red, blue, green, yellow, purple, orange)
 * @param {number} options.typingSpeed - Speed of typing effect in milliseconds (default: 50)
 * @param {boolean} options.append - Whether to append to existing text (default: true)
 */
function AddLine(message, options = {}) {
  const container = document.getElementById('text-container');
  const defaults = {
    color: null,
    typingSpeed: 50,
    append: true
  };

  // Merge default options with provided options
  const settings = {...defaults, ...options};

  // Create new line element
  const lineElement = document.createElement('div');
  lineElement.className = 'text-line';
  
  // Add color class if specified (for the entire line default color)
  if (settings.color) {
    lineElement.classList.add(`color-${settings.color}`);
  }
  
  // Clear all existing lines if not appending
  if (!settings.append) {
    DeleteAllLine(0);
  }
  
  // Add the empty element to container
  container.appendChild(lineElement);
  
  // Parse the message for color tags
  const colorParts = parseColorTags(message);
  
  // Setup for the typing effect
  let displayedChars = 0;
  let totalChars = 0;
  
  // Calculate total characters (excluding color tags)
  colorParts.forEach(part => {
    if (part.type === 'text') {
      totalChars += part.content.length;
    }
  });
  
  // Initialize with empty spans for each color segment
  const segments = [];
  let currentSpan = document.createElement('span');
  lineElement.appendChild(currentSpan);
  
  // Populate initial structure with empty spans
  colorParts.forEach(part => {
    if (part.type === 'color') {
      currentSpan = document.createElement('span');
      
      // Apply the color style
      if (part.content.startsWith('#')) {
        // Hex color
        currentSpan.style.color = part.content;
      } else {
        // Named color
        currentSpan.classList.add(`color-${part.content.toLowerCase()}`);
      }
      
      lineElement.appendChild(currentSpan);
    } else if (part.type === 'text') {
      segments.push({
        span: currentSpan,
        text: part.content,
        displayed: 0
      });
    }
  });
  
  // Create typing effect
  const typingInterval = setInterval(() => {
    if (displayedChars < totalChars) {
      // Find the segment where the next character should be added
      for (let i = 0; i < segments.length; i++) {
        const segment = segments[i];
        
        if (segment.displayed < segment.text.length) {
          // Add the next character from this segment
          segment.displayed++;
          segment.span.textContent = segment.text.substring(0, segment.displayed);
          displayedChars++;
          break;
        }
      }
    } else {
      clearInterval(typingInterval);
    }
  }, settings.typingSpeed);
  
  return lineElement;
}

/**
 * Parse a message string for color tags and return an array of text/color parts
 * @param {string} message - The message with potential color tags
 * @return {Array} Array of objects with type (text or color) and content
 */
function parseColorTags(message) {
  const result = [];
  const regex = /\^([A-Z]+|#[0-9A-F]{6})/g;
  let lastIndex = 0;
  let match;
  
  while ((match = regex.exec(message)) !== null) {
    // Add text before the tag
    if (match.index > lastIndex) {
      result.push({
        type: 'text',
        content: message.substring(lastIndex, match.index)
      });
    }
    
    // Add the color marker
    result.push({
      type: 'color',
      content: match[1] // The color name or hex code
    });
    
    lastIndex = regex.lastIndex;
  }
  
  // Add remaining text
  if (lastIndex < message.length) {
    result.push({
      type: 'text',
      content: message.substring(lastIndex)
    });
  }
  
  return result;
}

/**
 * Remove all text lines with a fade out effect
 * @param {number} fadeTime - Duration of fade effect in milliseconds (default: 500)
 * @param {Function} callback - Function to call after deletion completes
 */
function DeleteAllLine(fadeTime = 500, callback = null) {
  const container = document.getElementById('text-container');
  const lines = container.querySelectorAll('.text-line');
  
  // If there are no lines, just call the callback
  if (lines.length === 0 && callback) {
    callback();
    return;
  }
  
  // Add fade-out class to all lines
  lines.forEach(line => {
    line.classList.add('fade-out');
  });
  
  // Remove the elements after the fade animation
  setTimeout(() => {
    while (container.firstChild) {
      container.removeChild(container.firstChild);
    }
    
    if (callback) {
      callback();
    }
  }, fadeTime);
}

/**
 * Change text with smooth transitions
 * @param {string|string[]} messages - Message or array of messages to display
 * @param {Object} options - Configuration options
 */
function ChangeText(messages, options = {}) {
  // Handle single message
  if (!Array.isArray(messages)) {
    messages = [messages];
  }
  
  DeleteAllLine(500, () => {
    // Add each message as a new line
    messages.forEach(msg => {
      AddLine(msg, options);
    });
  });
}

// Make functions available to external scripts
window.AddLine = AddLine;
window.DeleteAllLine = DeleteAllLine;
window.ChangeText = ChangeText;
