---
layout: default
title: "Modules de Formation"
permalink: /modules/
---

# Modules de Formation DevOps

Bienvenue dans notre parcours de formation DevOps complet. Chaque module est conçu pour vous faire progresser étape par étape dans la maîtrise des outils et pratiques DevOps essentiels.

{% include progress-indicators.html %}

## Parcours d'Apprentissage

<div class="modules-learning-path">
    {% assign phases = "Fondations,Automatisation,Intégration Continue,Orchestration et Monitoring,Projets Intégrés" | split: "," %}
    {% assign phase_modules = "01-fundamentals,05-docker|02-ansible,03-terraform|04-gitlab-ci|06-kubernetes,07-monitoring|08-projects" | split: "|" %}
    
    {% for phase_index in (0..4) %}
    <div class="learning-phase">
        <h3 class="phase-title">
            <span class="phase-number">{{ phase_index | plus: 1 }}</span>
            {{ phases[phase_index] }}
        </h3>
        
        <div class="phase-modules">
            {% assign current_phase_modules = phase_modules[phase_index] | split: "," %}
            {% for module_id in current_phase_modules %}
            {% assign module = site.data.modules.modules | where: "id", module_id | first %}
            {% if module %}
            <div class="module-card-compact" data-module-id="{{ module.id }}">
                <div class="module-card-header">
                    <h4 class="module-card-title">
                        <a href="{{ '/modules/' | append: module.id | append: '/' | relative_url }}">
                            {{ module.title }}
                        </a>
                    </h4>
                    <div class="module-card-badges">
                        <span class="difficulty-badge difficulty-{{ module.level }}">
                            {{ module.level | capitalize }}
                        </span>
                        <span class="duration-badge">{{ module.duration }}</span>
                    </div>
                </div>
                
                <div class="module-card-progress">
                    <div class="progress-bar">
                        <div class="progress-fill" data-module="{{ module.id }}" style="width: 0%"></div>
                    </div>
                    <span class="progress-text" data-module="{{ module.id }}">0%</span>
                </div>
                
                {% if module.objectives %}
                <div class="module-card-objectives">
                    <ul>
                        {% for objective in module.objectives limit: 2 %}
                        <li>{{ objective }}</li>
                        {% endfor %}
                        {% if module.objectives.size > 2 %}
                        <li class="objectives-more">+{{ module.objectives.size | minus: 2 }} autres objectifs</li>
                        {% endif %}
                    </ul>
                </div>
                {% endif %}
                
                {% if module.prerequisites.size > 0 %}
                <div class="module-card-prerequisites">
                    <span class="prerequisites-label">Prérequis:</span>
                    {% for prereq_id in module.prerequisites %}
                    {% assign prereq = site.data.modules.modules | where: "id", prereq_id | first %}
                    <span class="prerequisite-tag" data-prereq="{{ prereq_id }}">
                        {{ prereq.title | truncate: 15 }}
                    </span>
                    {% endfor %}
                </div>
                {% endif %}
                
                <div class="module-card-actions">
                    <a href="{{ '/modules/' | append: module.id | append: '/' | relative_url }}" 
                       class="btn btn-primary">
                        Commencer
                    </a>
                </div>
            </div>
            {% endif %}
            {% endfor %}
        </div>
    </div>
    {% endfor %}
</div>

## Comment Utiliser Cette Plateforme

<div class="usage-guide">
    <div class="guide-item">
        <span class="guide-icon">📚</span>
        <div class="guide-content">
            <h4>Suivez l'ordre recommandé</h4>
            <p>Chaque module s'appuie sur les précédents pour une progression optimale</p>
        </div>
    </div>
    
    <div class="guide-item">
        <span class="guide-icon">🐳</span>
        <div class="guide-content">
            <h4>Pratiquez avec Docker</h4>
            <p>Tous les exercices utilisent des environnements Docker isolés et reproductibles</p>
        </div>
    </div>
    
    <div class="guide-item">
        <span class="guide-icon">✅</span>
        <div class="guide-content">
            <h4>Validez vos acquis</h4>
            <p>Utilisez les indicateurs de progression pour suivre votre avancement</p>
        </div>
    </div>
    
    <div class="guide-item">
        <span class="guide-icon">📖</span>
        <div class="guide-content">
            <h4>Consultez les références</h4>
            <p>Chaque module inclut des sources pour approfondir vos connaissances</p>
        </div>
    </div>
</div>

---

**Prêt à commencer ?** Votre progression est automatiquement sauvegardée. Cliquez sur le premier module pour débuter votre parcours DevOps !

<script>
document.addEventListener('DOMContentLoaded', function() {
    initializeModulesPage();
});

function initializeModulesPage() {
    const progressData = JSON.parse(localStorage.getItem('devops_course_progress') || '{}');
    
    // Mettre à jour la progression de chaque module
    document.querySelectorAll('[data-module-id]').forEach(card => {
        const moduleId = card.dataset.moduleId;
        const progress = progressData[moduleId] || 0;
        
        const progressFill = card.querySelector(`[data-module="${moduleId}"].progress-fill`);
        const progressText = card.querySelector(`[data-module="${moduleId}"].progress-text`);
        
        if (progressFill) {
            progressFill.style.width = progress + '%';
        }
        
        if (progressText) {
            progressText.textContent = Math.round(progress) + '%';
        }
        
        // Mettre à jour l'état des prérequis
        card.querySelectorAll('[data-prereq]').forEach(prereqTag => {
            const prereqId = prereqTag.dataset.prereq;
            const prereqProgress = progressData[prereqId] || 0;
            
            if (prereqProgress >= 100) {
                prereqTag.classList.add('completed');
            } else if (prereqProgress > 0) {
                prereqTag.classList.add('in-progress');
            }
        });
        
        // Mettre à jour le bouton d'action
        const actionBtn = card.querySelector('.btn');
        if (progress >= 100) {
            actionBtn.textContent = 'Revoir';
            actionBtn.classList.add('completed');
        } else if (progress > 0) {
            actionBtn.textContent = 'Continuer';
            actionBtn.classList.add('in-progress');
        }
    });
}
</script>