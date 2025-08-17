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

// Navigation responsive moderne
function initResponsiveNav() {
    const navToggle = document.getElementById('navToggle');
    const navMenu = document.getElementById('navMenu');
    
    if (!navToggle || !navMenu) return;
    
    navToggle.addEventListener('click', function() {
        const isOpen = navMenu.classList.contains('nav-open');
        
        if (isOpen) {
            navMenu.classList.remove('nav-open');
            navToggle.classList.remove('active');
            navToggle.setAttribute('aria-expanded', 'false');
        } else {
            navMenu.classList.add('nav-open');
            navToggle.classList.add('active');
            navToggle.setAttribute('aria-expanded', 'true');
        }
    });
    
    // Fermer le menu en cliquant à l'extérieur
    document.addEventListener('click', function(e) {
        if (!navToggle.contains(e.target) && !navMenu.contains(e.target)) {
            navMenu.classList.remove('nav-open');
            navToggle.classList.remove('active');
            navToggle.setAttribute('aria-expanded', 'false');
        }
    });
    
    // Fermer le menu lors du redimensionnement
    window.addEventListener('resize', function() {
        if (window.innerWidth > 768) {
            navMenu.classList.remove('nav-open');
            navToggle.classList.remove('active');
            navToggle.setAttribute('aria-expanded', 'false');
        }
    });
    
    // Mettre à jour le badge de progression des modules
    updateModuleProgressBadge();
}

// Mettre à jour le badge de progression dans la navigation
function updateModuleProgressBadge() {
    const moduleProgressBadge = document.getElementById('moduleProgress');
    if (!moduleProgressBadge) return;
    
    const progressData = loadProgressData();
    const modules = {{ site.data.modules.modules | jsonify }};
    
    let completedModules = 0;
    modules.forEach(module => {
        const progress = progressData[module.id] || 0;
        if (progress === 100) {
            completedModules++;
        }
    });
    
    moduleProgressBadge.textContent = `${completedModules}/${modules.length}`;
}

// Fonction utilitaire pour charger les données de progression
function loadProgressData() {
    const saved = localStorage.getItem('devops_course_progress');
    return saved ? JSON.parse(saved) : {};
}

// Fonction pour sauvegarder les données de progression
function saveProgressData(data) {
    localStorage.setItem('devops_course_progress', JSON.stringify(data));
    
    // Mettre à jour le badge de navigation
    updateModuleProgressBadge();
    
    // Déclencher un événement personnalisé pour les autres composants
    window.dispatchEvent(new CustomEvent('progressUpdated', { detail: data }));
}
// Gestion
 de la progression des modules
function initModuleProgress() {
    // Écouter les changements de progression
    window.addEventListener('progressUpdated', function(e) {
        updateAllProgressIndicators(e.detail);
    });
    
    // Initialiser la progression si on est sur une page de module
    if (document.body.classList.contains('module-page')) {
        initCurrentModuleProgress();
    }
}

// Initialiser la progression du module actuel
function initCurrentModuleProgress() {
    const moduleId = document.body.dataset.moduleId;
    if (!moduleId) return;
    
    // Compter les sections et exercices
    const sections = document.querySelectorAll('h2, h3');
    const exercises = document.querySelectorAll('.exercise-section');
    const totalItems = sections.length + exercises.length;
    
    if (totalItems === 0) return;
    
    // Créer des checkboxes pour suivre la progression
    sections.forEach((section, index) => {
        const checkbox = createProgressCheckbox(`section_${index}`, section.textContent);
        section.appendChild(checkbox);
    });
    
    exercises.forEach((exercise, index) => {
        const checkbox = createProgressCheckbox(`exercise_${index}`, 'Exercice terminé');
        exercise.appendChild(checkbox);
    });
    
    // Mettre à jour la progression
    updateCurrentModuleProgress(moduleId, totalItems);
}

// Créer une checkbox de progression
function createProgressCheckbox(id, label) {
    const wrapper = document.createElement('div');
    wrapper.className = 'progress-checkbox';
    
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    checkbox.id = id;
    checkbox.className = 'progress-item';
    
    const labelElement = document.createElement('label');
    labelElement.htmlFor = id;
    labelElement.textContent = label;
    
    // Charger l'état sauvegardé
    const saved = localStorage.getItem(`progress_${id}`);
    if (saved === 'true') {
        checkbox.checked = true;
    }
    
    // Sauvegarder les changements
    checkbox.addEventListener('change', function() {
        localStorage.setItem(`progress_${id}`, this.checked);
        updateCurrentModuleProgress();
    });
    
    wrapper.appendChild(checkbox);
    wrapper.appendChild(labelElement);
    
    return wrapper;
}

// Mettre à jour la progression du module actuel
function updateCurrentModuleProgress(moduleId, totalItems) {
    if (!moduleId) {
        moduleId = document.body.dataset.moduleId;
    }
    
    if (!totalItems) {
        totalItems = document.querySelectorAll('.progress-item').length;
    }
    
    if (totalItems === 0) return;
    
    const completedItems = document.querySelectorAll('.progress-item:checked').length;
    const progress = (completedItems / totalItems) * 100;
    
    // Mettre à jour les indicateurs visuels
    const progressFill = document.getElementById('currentModuleProgress');
    const progressText = document.getElementById('currentModulePercentage');
    const progressItems = document.getElementById('currentModuleItems');
    
    if (progressFill) {
        progressFill.style.width = progress + '%';
    }
    
    if (progressText) {
        progressText.textContent = Math.round(progress) + '%';
    }
    
    if (progressItems) {
        progressItems.textContent = `${completedItems}/${totalItems} sections`;
    }
    
    // Sauvegarder la progression globale du module
    if (moduleId) {
        const progressData = loadProgressData();
        progressData[moduleId] = progress;
        saveProgressData(progressData);
    }
}

// Fonction pour marquer un module comme terminé
function completeModule(moduleId) {
    const progressData = loadProgressData();
    progressData[moduleId] = 100;
    saveProgressData(progressData);
    
    // Afficher une notification de félicitations
    showCompletionNotification(moduleId);
}

// Afficher une notification de fin de module
function showCompletionNotification(moduleId) {
    const notification = document.createElement('div');
    notification.className = 'completion-notification';
    notification.innerHTML = `
        <div class="notification-content">
            <span class="notification-icon">🎉</span>
            <div class="notification-text">
                <h4>Félicitations !</h4>
                <p>Vous avez terminé ce module avec succès.</p>
            </div>
            <button class="notification-close" onclick="this.parentElement.parentElement.remove()">×</button>
        </div>
    `;
    
    document.body.appendChild(notification);
    
    // Supprimer automatiquement après 5 secondes
    setTimeout(() => {
        if (notification.parentElement) {
            notification.remove();
        }
    }, 5000);
}

// Initialiser tous les composants au chargement de la page
document.addEventListener('DOMContentLoaded', function() {
    initValidationCheckboxes();
    initCodeCopyButtons();
    initResponsiveNav();
    initModuleProgress();
});