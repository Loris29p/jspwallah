// Variable globale pour le lecteur YouTube
let player;
let currentVideoTitle = '';

// Fonction appelée automatiquement par l'API YouTube lorsqu'elle est prête
function onYouTubeIframeAPIReady() {
    // Ne pas lancer automatiquement la vidéo, attendre l'appel de FiveM
    console.log("YouTube API ready");
}

// Fonction pour afficher une vidéo YouTube par son ID
window.displayYouTubeVideo = function(videoId) {
    // Récupérer les informations de la vidéo
    fetchVideoInfo(videoId)
        .then(videoInfo => {
            // Sauvegarder le titre pour une utilisation ultérieure
            currentVideoTitle = videoInfo.title;
            
            // Mettre à jour le titre de la vidéo
            const titleElement = document.querySelector('.video-title');
            titleElement.textContent = currentVideoTitle;
            
            // Si le lecteur existe déjà, charger la nouvelle vidéo
            if (player) {
                player.loadVideoById({
                    videoId: videoId,
                    suggestedQuality: 'hd1080'
                });
                return;
            }
            
            // Créer un nouveau lecteur YouTube
            player = new YT.Player('youtube-player', {
                height: '100%',
                width: '100%',
                videoId: videoId,
                playerVars: {
                    'autoplay': 1,        // Lecture automatique
                    'controls': 1,        // Afficher les contrôles
                    'loop': 1,            // Lecture en boucle
                    'playlist': videoId,  // Nécessaire pour la lecture en boucle
                    'rel': 0,             // Ne pas afficher les vidéos suggérées
                    'fs': 0,              // Désactiver le mode plein écran
                    'iv_load_policy': 3,  // Masquer les annotations
                    'modestbranding': 1,  // Affichage minimal du logo YouTube
                    'playsinline': 1,     // Lecture dans le cadre (important pour mobile)
                    'mute': 1,            // Mettre en sourdine (nécessaire pour que l'autoplay fonctionne)
                    'origin': window.location.origin, // Important pour FiveM
                    'enablejsapi': 1,     // Activer l'API JavaScript
                    'vq': 'hd1080'        // Qualité vidéo maximale
                },
                events: {
                    'onReady': onPlayerReady,
                    'onStateChange': onPlayerStateChange,
                    'onError': onPlayerError
                }
            });
        })
        .catch(error => {
            console.error('Erreur lors de la récupération des informations de la vidéo:', error);
        });
};

// Fonction pour gérer les erreurs du lecteur
function onPlayerError(event) {
    console.error('Erreur du lecteur YouTube:', event.data);
    
    // Afficher des informations supplémentaires sur l'erreur
    let errorMessage = '';
    switch(event.data) {
        case 2:
            errorMessage = "ID de vidéo invalide";
            break;
        case 5:
            errorMessage = "Erreur HTML5 du lecteur";
            break;
        case 100:
            errorMessage = "Vidéo non trouvée ou supprimée";
            break;
        case 101:
        case 150:
            errorMessage = "La lecture de cette vidéo n'est pas autorisée dans un lecteur intégré";
            // Essayer une autre méthode d'intégration pour les vidéos avec restrictions
            try {
                const videoId = player.getVideoData().video_id;
                tryAlternativeEmbedding(videoId);
            } catch (e) {
                console.error("Impossible de récupérer l'ID de la vidéo:", e);
            }
            break;
        default:
            errorMessage = "Erreur inconnue";
    }
    console.error('Détail de l\'erreur:', errorMessage);
}

// Fonction pour essayer une méthode alternative d'intégration
function tryAlternativeEmbedding(videoId) {
    console.log("Tentative d'intégration alternative pour la vidéo:", videoId);
    
    // S'assurer que le titre est toujours affiché
    const titleElement = document.querySelector('.video-title');
    if (titleElement && currentVideoTitle) {
        titleElement.textContent = currentVideoTitle;
    } else if (titleElement) {
        // Si nous n'avons pas encore le titre, essayer de le récupérer à nouveau
        fetchVideoInfo(videoId)
            .then(videoInfo => {
                currentVideoTitle = videoInfo.title;
                titleElement.textContent = currentVideoTitle;
            })
            .catch(error => {
                console.error('Erreur lors de la récupération des informations de la vidéo:', error);
                titleElement.textContent = 'Vidéo YouTube';
            });
    }
    
    // Vider le conteneur existant
    const youtubePlayer = document.getElementById('youtube-player');
    youtubePlayer.innerHTML = '';
    
    // Créer un iframe directement (contourne certaines restrictions)
    const iframe = document.createElement('iframe');
    iframe.width = '100%';
    iframe.height = '100%';
    iframe.src = `https://www.youtube.com/embed/${videoId}?autoplay=1&mute=1&controls=1&loop=1&playlist=${videoId}&modestbranding=1&origin=${encodeURIComponent(window.location.origin)}`;
    iframe.frameBorder = '0';
    iframe.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
    iframe.allowFullscreen = true;
    
    youtubePlayer.appendChild(iframe);
    
    // Réinitialiser la variable player
    player = null;
    
    // Ajouter un bouton pour le son (puisque onPlayerReady ne sera pas appelé)
    addSoundButton();
}

// Fonction pour ajouter le bouton de son
function addSoundButton() {
    // Supprimer le bouton existant s'il y en a un
    const existingButton = document.querySelector('.sound-button');
    if (existingButton) {
        existingButton.remove();
    }
    
    const videosContainer = document.querySelector('.videos-container');
    const soundButton = document.createElement('button');
    soundButton.className = 'sound-button';
    soundButton.textContent = 'Activer le son';
    soundButton.style.marginTop = '10px';
    soundButton.style.padding = '8px 16px';
    soundButton.style.backgroundColor = '#ff0000';
    soundButton.style.color = 'white';
    soundButton.style.border = 'none';
    soundButton.style.borderRadius = '4px';
    soundButton.style.cursor = 'pointer';
    
    soundButton.addEventListener('click', function() {
        if (player && player.isMuted) {
            if (player.isMuted()) {
                player.unMute();
                soundButton.textContent = 'Désactiver le son';
            } else {
                player.mute();
                soundButton.textContent = 'Activer le son';
            }
        } else {
            // Pour l'intégration alternative
            const iframe = document.querySelector('#youtube-player iframe');
            if (iframe) {
                // Basculer le paramètre mute dans l'URL de l'iframe
                const currentSrc = iframe.src;
                if (currentSrc.includes('mute=1')) {
                    iframe.src = currentSrc.replace('mute=1', 'mute=0');
                    soundButton.textContent = 'Désactiver le son';
                } else {
                    iframe.src = currentSrc.replace('mute=0', 'mute=1');
                    soundButton.textContent = 'Activer le son';
                }
            }
        }
    });
    
    videosContainer.appendChild(soundButton);
}

// Fonction pour arrêter la vidéo et nettoyer l'interface
window.stopYouTubeVideo = function() {
    // Réinitialiser le titre
    currentVideoTitle = '';
    
    if (player) {
        player.stopVideo();
        const titleElement = document.querySelector('.video-title');
        if (titleElement) {
            titleElement.textContent = '';
        }
        
        // Supprimer le bouton de son s'il existe
        const soundButton = document.querySelector('.sound-button');
        if (soundButton) {
            soundButton.remove();
        }
        
        // Vider le conteneur de la vidéo
        const youtubePlayer = document.getElementById('youtube-player');
        if (youtubePlayer) {
            youtubePlayer.innerHTML = '';
        }
        
        // Détruire l'instance du lecteur
        player.destroy();
        player = null;
    } else {
        // Si player n'existe pas, vérifier s'il y a un iframe à supprimer
        const youtubePlayer = document.getElementById('youtube-player');
        if (youtubePlayer) {
            youtubePlayer.innerHTML = '';
        }
        
        const titleElement = document.querySelector('.video-title');
        if (titleElement) {
            titleElement.textContent = '';
        }
        
        const soundButton = document.querySelector('.sound-button');
        if (soundButton) {
            soundButton.remove();
        }
    }
};

// Fonction appelée lorsque le lecteur est prêt
function onPlayerReady(event) {
    // Démarrer la lecture
    event.target.playVideo();
    // S'assurer que la vidéo est en sourdine pour permettre l'autoplay
    event.target.mute();
    
    // Ajouter le bouton de son
    addSoundButton();
}

// Fonction appelée lorsque l'état du lecteur change
function onPlayerStateChange(event) {
    // Si la vidéo est terminée (YT.PlayerState.ENDED = 0)
    if (event.data === YT.PlayerState.ENDED) {
        // Redémarrer la vidéo pour assurer la lecture en boucle
        event.target.playVideo();
    }
}

// Fonction pour récupérer les informations de la vidéo
async function fetchVideoInfo(videoId) {
    try {
        // Méthode alternative sans API key - récupère le titre via une requête à la page de la vidéo
        const response = await fetch(`https://noembed.com/embed?url=https://www.youtube.com/watch?v=${videoId}`);
        const data = await response.json();
        return {
            title: data.title || 'Vidéo YouTube'
        };
    } catch (error) {
        console.error('Erreur lors de la récupération des informations de la vidéo:', error);
        return {
            title: 'Vidéo YouTube'
        };
    }
}

// Pour FiveM, on peut recevoir l'ID de la vidéo depuis le client NUI
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'displayYouTubeVideo' && data.videoId) {
        displayYouTubeVideo(data.videoId);
    } else if (data.type === 'stopYouTubeVideo') {
        stopYouTubeVideo();
    }
});

// Ajouter un gestionnaire d'erreurs global
window.addEventListener('error', function(event) {
    console.error('Erreur JavaScript:', event.message, 'à', event.filename, 'ligne', event.lineno);
});