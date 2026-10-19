using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using UnityEngine;
using UnityEngine.Networking;

public class DatabaseSend : MonoBehaviour
{
    // Folder on the server where the PHP scripts of server/Sending are
    [SerializeField] private string serverURL = "https://citmalumnes.upc.es/~mariomr2/server/Sending/";

    // Times a request is repeated if the connection fails before giving up
    [SerializeField] private int maxRetries = 3;
    [SerializeField] private float retryDelay = 1.0f;

    #region Setup

    // The teacher's scene is used as it is, so this object is not placed in it by hand.
    // When the game starts, if the scene has a Simulator, a "DatabaseSend" object is
    // created automatically. This happens before the Simulator's Start, so no event is missed.
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    private static void CreateOnStart()
    {
        if (FindFirstObjectByType<Simulator>() != null)
        {
            new GameObject("DatabaseSend").AddComponent<DatabaseSend>();
        }
    }

    #endregion

    #region Subscribe

    // Listen to the events of the simulator
    private void OnEnable()
    {
        Simulator.OnNewPlayer += CreateUser;
        Simulator.OnNewSession += StartSession;
        Simulator.OnEndSession += EndSession;
        Simulator.OnBuyItem += BuyItem;
    }

    private void OnDisable()
    {
        Simulator.OnNewPlayer -= CreateUser;
        Simulator.OnNewSession -= StartSession;
        Simulator.OnEndSession -= EndSession;
        Simulator.OnBuyItem -= BuyItem;
    }

    #endregion

    #region Events

    // A new player appears: save it and give the simulator its user ID
    private void CreateUser(string name, string country, int age, float gender, DateTime date)
    {
        Dictionary<string, string> data = new Dictionary<string, string>
        {
            { "name", name },
            { "country", country },
            { "age", age.ToString() },
            { "gender", gender.ToString(CultureInfo.InvariantCulture) }, // Always "0.5", never "0,5"
            { "date", FormatDate(date) }
        };

        StartCoroutine(SendDataToServer("CreateUser.php", data, (userID) =>
        {
            CallbackEvents.OnAddPlayerCallback?.Invoke(userID);
        }));
    }

    // A player starts playing: save the session and give the simulator its session ID
    private void StartSession(DateTime date, uint userID)
    {
        Dictionary<string, string> data = new Dictionary<string, string>
        {
            { "userID", userID.ToString() },
            { "start", FormatDate(date) }
        };

        StartCoroutine(SendDataToServer("StartSession.php", data, (sessionID) =>
        {
            CallbackEvents.OnNewSessionCallback?.Invoke(sessionID);
        }));
    }

    // A player buys an item: save the purchase and give the simulator back the session ID
    private void BuyItem(int itemID, DateTime date, uint sessionID)
    {
        Dictionary<string, string> data = new Dictionary<string, string>
        {
            { "sessionID", sessionID.ToString() },
            { "itemID", itemID.ToString() },
            { "date", FormatDate(date) }
        };

        StartCoroutine(SendDataToServer("BuyItem.php", data, (returnedSessionID) =>
        {
            CallbackEvents.OnItemBuyCallback?.Invoke(returnedSessionID);
        }));
    }

    // A player stops playing: close the session and give the simulator the user ID
    private void EndSession(DateTime date, uint sessionID)
    {
        Dictionary<string, string> data = new Dictionary<string, string>
        {
            { "sessionID", sessionID.ToString() },
            { "end", FormatDate(date) }
        };

        StartCoroutine(SendDataToServer("EndSession.php", data, (userID) =>
        {
            CallbackEvents.OnEndSessionCallback?.Invoke(userID);
        }));
    }

    #endregion

    #region Sending

    // Sends the data to a PHP script without stopping the game (coroutine).
    // The PHP answers with an ID, which is passed to the callback.
    private IEnumerator SendDataToServer(string phpFile, Dictionary<string, string> data, Action<uint> callback)
    {
        string url = serverURL + phpFile;

        for (int attempt = 1; attempt <= maxRetries; attempt++)
        {
            // Put the data in a form, like an HTML form sent with POST
            WWWForm form = new WWWForm();
            foreach (KeyValuePair<string, string> entry in data)
            {
                form.AddField(entry.Key, entry.Value);
            }

            using (UnityWebRequest request = UnityWebRequest.Post(url, form))
            {
                // Wait for the answer without blocking the game
                yield return request.SendWebRequest();

                if (request.result == UnityWebRequest.Result.Success)
                {
                    string response = request.downloadHandler.text.Trim();

                    // The PHP returns the ID, or a text starting with "Error"
                    if (uint.TryParse(response, out uint id))
                    {
                        callback?.Invoke(id);
                    }
                    else
                    {
                        Debug.LogError($"{phpFile} answered: {response}");
                    }
                    yield break;
                }

                Debug.LogWarning($"Connection error sending to {phpFile} (attempt {attempt}/{maxRetries}): {request.error}");
            }

            // Wait a moment before trying again
            yield return new WaitForSeconds(retryDelay);
        }

        Debug.LogError($"Could not send data to {phpFile} after {maxRetries} attempts.");
    }

    // Date format expected by the PHP scripts and MySQL: YYYY-MM-DD HH:MM:SS
    private string FormatDate(DateTime date)
    {
        return date.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture);
    }

    #endregion
}
