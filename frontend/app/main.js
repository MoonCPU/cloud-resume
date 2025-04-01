async function updateVisitorCounter() {
    try {
        // send POST request to increment the count and get the updated value
        const response = await fetch('my-url', {
            method: 'POST',
        });

        // parse the response and update the counter on the page
        const data = await response.json();
        document.getElementById('visitorCount').innerText = data.count;

    } catch (error) {
        console.log(error);
    }
}