import React, { useState } from 'react';
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View, Button, TextInput, Image, TouchableOpacity } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import * as ImagePicker from 'expo-image-picker';
import { Alert } from 'react-native'

const Stack = createNativeStackNavigator();

function AuthScreen({ navigation }) {
  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');

  const handleAuth = () => {
    //email verification
    if (!email.endsWith('.edu')) {
      Alert.alert('Invalid Email', 'Please use your .edu email address to continue.');
      return;
    }
    if (!email || !password || (isSignUp && !name)) {
      Alert.alert('Missing Fields', 'Please fill out all required fields.');
      return;
    }
    //simulated access
    Alert.alert(
      isSignUp ? 'Account Created' : 'Login Successful',
      `Welcome, ${isSignUp ? name : email}!`
    );
    navigation.replace('Home');
  };

  return (
    <View style={styles.authContainer}>
      <Text style={styles.appTitle}>RideMate</Text>
      <Text style={styles.subtitle}>{isSignUp ? 'Create your account' : 'Welcome back'}</Text>

      {isSignUp && (
        <TextInput 
          style={styles.input}
          placeholder="Full Name"
          value={name}
          onChangeText={setName}/>
      )}

      <TextInput 
        style={styles.input}
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        keyboardType="email-address"
        autoCapitalize="none" />

      <TextInput 
        style={styles.input}
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry />

      <TouchableOpacity style={styles.button} onPress={handleAuth}>
        <Text style={styles.buttonText}>{isSignUp ? 'Sign Up' : 'Login'}</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={() => setIsSignUp(!isSignUp)}>
        <Text style={styles.switchText}>
          {isSignUp ? 'Already have an account? Login' : "Don't have an account? Sign Up"}
        </Text>
      </TouchableOpacity>

      <StatusBar style="auto" />

    </View>
  );
}

function HomeScreen({ navigation })
{
  return (
    <View style={styles.container}>
      <Text style={styles.title}>RideMate</Text>
      <Button title="Profile" onPress={() => navigation.navigate('Profile')}/>
      <StatusBar style="auto" />
    </View>
  );
}

function ProfileScreen()
{
  const [isEditing, setIsEditing] = useState(false);
  const [name, setName] = useState('Anthony Raemsch');
  const [email, setEmail] = useState('araems1@lsu.edu');
  const [image, setImage] = useState(null);

  const pickImage = async() => {
    try
    {
      const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();

      if (!permissionResult.granted)
      {
        alert('Permission to access gallery is required!');
        return;
      }

      const result = await ImagePicker.launchImageLibraryAsync({mediaTypes: ImagePicker.MediaTypeOptions.Images, allowsEditing: true, aspect: [1, 1], quality: 1,});

      if (!result.canceled && result.assets && result.assets.length > 0)
      {
        setImage(result.assets[0].uri);
      }
    }

    catch (error)
    {
      console.error('Image picker error: ', error);
      alert('Something went wrong while picking the image.');
    } 
  };

  return (
    <View style={styles.container}>
      {isEditing ? (
        <TouchableOpacity onPress={pickImage}>
        {image ? (
          <Image source={{ uri: image }} style={styles.profileImage}/>
        ) : (
          <View style={[styles.profileImage, styles.placeholder]}>
            <Text style={{ color: '#888' }}>Tap to add photo</Text>
          </View>
          )}
      </TouchableOpacity>
      ): (
        <Image
          source={image ? {uri : image} : null}
          style={[styles.profileImage, !image && styles.placeholder]}
        />
      )}

      {isEditing ? (
        <TextInput
          style={styles.input}
          value={name}
          onChangeText={setName}
        />
      ) : (
          <Text style={styles.text}>Name: {name}</Text>
        
      )}
      
      {isEditing ? (
        <TextInput
          style={styles.input}
          value={email}
          onChangeText={setEmail}
        />
      ) : (
        <Text style={styles.text}>Email: {email}</Text>
      )}

      <Button title={isEditing ? "Save Profile" : 'Edit Profile'}
      onPress={() => 
      {
        if (isEditing)
        {
          alert('Profile saved!');
        }

        setIsEditing(!isEditing);
      }}
      />
    </View>
  );
}

export default function App()
{
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Auth">
        <Stack.Screen name="Auth" component={AuthScreen} options={{ headerShown: false}}/>
        <Stack.Screen name="Home" component={HomeScreen}/>
        <Stack.Screen name="Profile" component={ProfileScreen}/>
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create
({
  authContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f2f4f8',
    padding: 20,
  },
  appTitle: {
    fontSize: 36,
    fontWeight: 'bold',
    color: '#0004aad',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 18,
    color: '#555', marginBottom: 20,
  },
  input: {
    width: '90%',
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 10,
    padding: 12,
    marginVertical: 8,
    backgroundColor: '#fff',
  },
  button: { 
    backgroundColor: '#004aad',
    borderRadius: 10,
    paddingVertical: 12,
    paddingHorizontal: 50,
    marginTop: 10,
  },
  buttonText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: '600',
  },
  switchText: {
    color: '#004aad',
    marginTop: 15,
    fontSize: 15,
  },
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontSize: 28, 
    fontWeight: 'bold',
    marginBottom: 20,
  },
  profileImage: { 
    width: 120, 
    height: 120, 
    borderRadius: 60,
    marginBttom: 20,
    backgroundColor: '#eee',
  },
  placeholder: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  text: {
    fontSize: 18,
    marginVertical: 5,
  },
});