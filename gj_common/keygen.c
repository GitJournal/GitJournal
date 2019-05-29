#include "gitjournal.h"

#include <stdio.h>
#include <string.h>
#include <sys/stat.h>

#include <memory.h>

#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/err.h>
#include <openssl/rsa.h>

static unsigned char pSshHeader[11] = {0x00, 0x00, 0x00, 0x07, 0x73, 0x73, 0x68, 0x2D, 0x72, 0x73, 0x61};

static int SshEncodeBuffer(unsigned char *pEncoding, int bufferLen, unsigned char *pBuffer)
{
   int adjustedLen = bufferLen, index;
   if (*pBuffer & 0x80)
   {
      adjustedLen++;
      pEncoding[4] = 0;
      index = 5;
   }
   else
   {
      index = 4;
   }
   pEncoding[0] = (unsigned char)(adjustedLen >> 24);
   pEncoding[1] = (unsigned char)(adjustedLen >> 16);
   pEncoding[2] = (unsigned char)(adjustedLen >> 8);
   pEncoding[3] = (unsigned char)(adjustedLen);
   memcpy(&pEncoding[index], pBuffer, bufferLen);
   return index + bufferLen;
}

int write_rsa_public_key(RSA *pRsa, const char *file_path, const char *comment)
{
   int ret = 0;
   int encodingLength = 0;
   int index = 0;
   unsigned char *nBytes = NULL, *eBytes = NULL;
   unsigned char *pEncoding = NULL;
   FILE *pFile = NULL;
   BIO *bio, *b64;

   ERR_load_crypto_strings();
   OpenSSL_add_all_algorithms();

   const BIGNUM *pRsa_mod = NULL;
   const BIGNUM *pRsa_exp = NULL;

   RSA_get0_key(pRsa, &pRsa_mod, &pRsa_exp, NULL);

   // reading the modulus
   int nLen = BN_num_bytes(pRsa_mod);
   nBytes = (unsigned char *)malloc(nLen);
   ret = BN_bn2bin(pRsa_mod, nBytes);
   if (ret <= 0)
      goto cleanup;

   // reading the public exponent
   int eLen = BN_num_bytes(pRsa_exp);
   eBytes = (unsigned char *)malloc(eLen);
   ret = BN_bn2bin(pRsa_exp, eBytes);
   if (ret <= 0)
      goto cleanup;

   encodingLength = 11 + 4 + eLen + 4 + nLen;
   // correct depending on the MSB of e and N
   if (eBytes[0] & 0x80)
      encodingLength++;
   if (nBytes[0] & 0x80)
      encodingLength++;

   pEncoding = (unsigned char *)malloc(encodingLength);
   memset(pEncoding, 0, encodingLength);
   memcpy(pEncoding, pSshHeader, 11);

   index = SshEncodeBuffer(&pEncoding[11], eLen, eBytes);
   index = SshEncodeBuffer(&pEncoding[11 + index], nLen, nBytes);

   b64 = BIO_new(BIO_f_base64());
   BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);

   pFile = fopen(file_path, "w");
   bio = BIO_new_fp(pFile, BIO_CLOSE);
   BIO_printf(bio, "ssh-rsa ");
   bio = BIO_push(b64, bio);
   BIO_write(bio, pEncoding, encodingLength);
   BIO_flush(bio);
   bio = BIO_pop(b64);
   BIO_printf(bio, " %s\n", comment);
   BIO_flush(bio);
   BIO_free_all(bio);
   BIO_free(b64);

cleanup:
   if (pFile)
      fclose(pFile);

   free(nBytes);
   free(eBytes);
   free(pEncoding);

   EVP_cleanup();
   ERR_free_strings();

   return ret > 0 ? 1 : ret;
}

int gj_generate_ssh_keys(const char *private_key_path,
                         const char *public_key_path, const char *comment)
{
   int ret = 0;
   RSA *rsa = NULL;

   BIGNUM *bne = NULL;
   BIO *bp_private = NULL;

   int bits = 1024 * 4;
   unsigned long e = RSA_F4;

   // Generate rsa key
   bne = BN_new();
   ret = BN_set_word(bne, e);
   if (ret != 1)
      goto cleanup;

   rsa = RSA_new();
   ret = RSA_generate_key_ex(rsa, bits, bne, NULL);
   if (ret != 1)
   {
      gj_log_internal("Failed to generate RSA key of %d bits\n", bits);
      goto cleanup;
   }

   // Save private key
   bp_private = BIO_new_file(private_key_path, "w+");
   ret = PEM_write_bio_RSAPrivateKey(bp_private, rsa, NULL, NULL, 0, NULL, NULL);
   if (ret != 1)
   {
      gj_log_internal("Failed to write private key to %s\n", private_key_path);
      goto cleanup;
   }

   // Save public key
   ret = write_rsa_public_key(rsa, public_key_path, comment);
   if (ret != 1)
   {
      gj_log_internal("Failed to write public key to %s\n", public_key_path);
      goto cleanup;
   }

cleanup:
   BIO_free_all(bp_private);
   RSA_free(rsa);
   BN_free(bne);

   if (ret != 1)
      return GJ_ERR_OPENSSL;
   return 0;
}
