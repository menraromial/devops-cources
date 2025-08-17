// Main JavaScript for DevOps Course Platform

document.addEventListener('DOMContentLoaded', function() {
    // Initialize validation checkboxes for exercises
    initValidationCheckboxes();
    
    // Initialize code copy buttons
    initCodeCopyButtons();
    
    // Initialize responsive navigation
    initResponsiveNav();
});

// Exercise validation checkboxes
function initValidationCheckboxes() {
    const validationItems = document.querySelectorAll('.validation-item input[type="checkbox"]');
    
    validationItems.forEach(checkbox => {
        // Load saved state from localStorage
        const checkboxId = checkbox.id;
        const savedState = localStorage.getItem(`validation_${checkboxId}`);
        if (savedState === 'true') {
            checkbox.checked = true;
        }
        
        // Save state on change
        checkbox.addEventListener('change', function() {
            localStorage.setItem(`validation_${checkboxId}`, this.checked);
            updateValidationProgress();
        });
    });
    
    updateValidationProgress();
}

// Update validation progress
function updateValidationProgress() {
    const validationSection = document.querySelector('.exercise-validation');
    if (!validationSection) return;
    
    const checkboxes = validationSection.querySelectorAll('input[type="checkbox"]');
    const checkedBoxes = validationSection.querySelectorAll('input[type="checkbox"]:checked');
    
    if (checkboxes.length === 0) return;
    
    const progress = (checkedBoxes.length / checkboxes.length) * 100;
    
    // Create or update progress bar
    let progressBar = validationSection.querySelector('.validation-progress');
    if (!progressBar) {
        progressBar = document.createElement('div');
        progressBar.className = 'validation-progress';
        progressBar.innerHTML = `
            <div class="progress-bar">
                <div class="progress-fill"></div>
            </div>
            <span class="progress-text">Progression: 0%</span>
        `;
        validationSection.insertBefore(progressBar, validationSection.firstChild);
    }
    
    const progressFill = progressBar.querySelector('.progress-fill');
    const progressText = progressBar.querySelector('.progress-text');
    
    progressFill.style.width = progress + '%';
    progressText.textContent = `Progression: ${Math.round(progress)}%`;
    
    // Add completion message
    if (progress === 100) {
        progressText.textContent = '✅ Exercice terminé !';
        progressText.style.color = '#27ae60';
    }
}

// Add copy buttons to code blocks
function initCodeCopyButtons() {
    const codeBlocks = document.querySelectorAll('.highlight pre');
    
    codeBlocks.forEach(block => {
        const button = document.createElement('button');
        button.className = 'copy-code-btn';
        button.textContent = 'Copier';
        button.setAttribute('aria-label', 'Copier le code');
        
        const wrapper = document.createElement('div');
        wrapper.className = 'code-block-wrapper';
        
        block.parentNode.insertBefore(wrapper, block);
        wrapper.appendChild(button);
        wrapper.appendChild(block);
        
        button.addEventListener('click', function() {
            const code = block.textContent;
            navigator.clipboard.writeText(code).then(() => {
                button.textContent = 'Copié !';
                button.style.background = '#27ae60';
                setTimeout(() => {
                    button.textContent = 'Copier';
                    button.style.background = '';
                }, 2000);
            }).catch(() => {
                // Fallback for older browsers
                const textArea = document.createElement('textarea');
                textArea.value = code;
                document.body.appendChild(textArea);
                textArea.select();
                document.execCommand('copy');
                document.body.removeChild(textArea);
                
                button.textContent = 'Copié !';
                setTimeout(() => {
                    button.textContent = 'Copier';
                }, 2000);
            });
        });
    });
}

// Responsive navigation
function initResponsiveNav() {
    const nav = document.querySelector('.main-nav');
    if (!nav) return;
    
    // Add mobile menu toggle
    const header = document.querySelector('.site-header .container');
    const toggleButton = document.createElement('button');
    toggleButton.className = 'nav-toggle';
    toggleButton.innerHTML = '☰';
    toggleButton.setAttribute('aria-label', 'Toggle navigation');
    
    header.appendChild(toggleButton);
    
    toggleButton.addEventListener('click', function() {
        nav.classList.toggle('nav-open');
        this.classList.toggle('active');
    });
    
    // Close menu when clicking outside
    document.addEventListener('click', function(e) {
        if (!header.contains(e.target)) {
            nav.classList.remove('nav-open');
            toggleButton.classList.remove('active');
        }
    });
}