import { Router } from 'express';
import { verifyFirebaseToken } from '../middlewares/auth.middleware';
import dotenv from 'dotenv';
dotenv.config();

const router = Router();

// Endpoint EXCLUSIVO para testing en Swagger. (La app MAUI usará su propio SDK)
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const apiKey = process.env.FIREBASE_API_KEY;

  if (!apiKey) {
    return res.status(500).json({ error: 'Falta FIREBASE_API_KEY en .env' });
  }

  try {
    const response = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password, returnSecureToken: true })
    });

    const data = await response.json();

    if (!response.ok) {
      return res.status(401).json({ error: data.error.message });
    }

    // Devuelve el token JWT necesario para Swagger
    res.status(200).json({
      success: true,
      idToken: data.idToken,
      email: data.email,
      localId: data.localId
    });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/verify-login', verifyFirebaseToken, (req, res) => {
  const user = (req as any).user;
  res.status(200).json({ 
    success: true, 
    message: 'Token válido',
    uid: user.uid,
    role: user.role,
    restaurantId: user.restaurantId
  });
});

export default router;
