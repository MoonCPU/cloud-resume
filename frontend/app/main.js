document.addEventListener('DOMContentLoaded', function() {
    updateVisitorCounter(); // Call the function as early as possible
});

async function updateVisitorCounter() {
    try {
        const response = await fetch("https://x7uijxsiec.execute-api.sa-east-1.amazonaws.com/prod/count", {
            method: 'POST',
        });

        const data = await response.json();
        document.getElementById('visitorCount').innerText = data.count;

    } catch (error) {
        console.error("Error updating visitor counter:", error);
    }
}