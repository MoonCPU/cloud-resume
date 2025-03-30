async function updateVisitorCounter() {
    try {
        // this will trigger the POST method in the Lambda Function API
        await fetch('my-url', {
            method: 'POST',
        });

        // GET request to retrieve the updated visitor count
        const response = await fetch('my-url', {
            method: 'GET',
        });

        // Assuming the response contains a field called visitorCount
        const data = await response.json();
        document.getElementById('visitorCount').innerText = data.visitorCount;

    } catch (error) {
        console.log(error);
    }
}