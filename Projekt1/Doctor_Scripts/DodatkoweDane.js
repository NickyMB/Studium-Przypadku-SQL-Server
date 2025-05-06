function toggleDane() {
    const div = document.getElementById('DaneDodatkowe');
    const btn = document.getElementById('toggleDaneDodatkowe');
    if (div.style.display === 'none' || div.style.display === '') {
        div.style.display = 'block';
        btn.textContent = 'Ukryj dodatkowe dane';
    } else {
        div.style.display = 'none';
        btn.textContent = 'Pokaż dodatkowe dane';
    }
}